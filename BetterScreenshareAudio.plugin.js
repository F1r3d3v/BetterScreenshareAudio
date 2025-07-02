/**
 * @name BetterScreenshareAudio
 * @author F1r3d3v
 * @authorLink https://github.com/F1r3d3v
 * @version 1.0.0
 * @source https://github.com/F1r3d3v/BetterScreenshareAudio
 * @description Choose the audio sources for the screenshare on Linux. Requires fork of BetterDiscord to work.
 */

const { Webpack, Patcher, React, Logger, Data, Components, Plugins } = BdApi;

const Dispatcher = Webpack.getByKeys("subscribe", "dispatch");
const UserStore = Webpack.getStore("UserStore");
const TextClasses = Webpack.getByKeys("errorMessage", "h5");
const Utilities = Webpack.getByKeys("getAudioPid", "getPidFromDesktopSource", "getDesktopSourceFromPid");

const fs = require("fs");
const path = require("path");
const venmic = require("venmic");

const defaultAudioSource = "system";
const discordAudioSource = "discord";
const defaultSettings = {
    "useBuildInSoundshare": false,
};

let settings = {};

module.exports = class BetterScreenshareAudio {
    constructor(meta) {
        this.meta = meta;
    }

    patch() {
        Patcher.unpatchAll(this.meta.name);
        Dispatcher.unsubscribe("VOICE_CHANNEL_SELECT", this.onVoiceChannelSelect);
        Dispatcher.unsubscribe("STREAM_CLOSE", this.onStreamClose);

        try {
            Dispatcher.subscribe("VOICE_CHANNEL_SELECT", this.onVoiceChannelSelect);
            Dispatcher.subscribe("STREAM_CLOSE", this.onStreamClose);
            this.customAudioSource();
        } catch (err) {
            Logger.error(this.meta.name, err);
        }
    }

    async customAudioSource() {
        // Wait for the modal to appear, then get the necessary modules
        if (!this.ModulesInitialized) {
            await Webpack.waitForModule(Webpack.Filters.byStrings("onChangeSound", "onChangePreviewDisabled"));

            this.GoLiveModalMod = Webpack.getMangled("showRefreshedGoLiveModal", {
                GoLiveModal: Webpack.Filters.byStrings("showRefreshedGoLiveModal")
            });

            this.StreamSettingsPanelMod = Webpack.getMangled(/onChangeSound:.{1,3},onChangePreviewDisabled:.{1,3}/, {
                GoLiveModal: x => x
            });

            this.FormModalClasses = Webpack.getByKeys("formItemTitleSlim", "modalContent");

            this.ModulesInitialized = true;
        }

        let activeSlide = undefined;
        let lastActiveSlide = undefined;
        let audioSource = [defaultAudioSource];

        Patcher.after(this.meta.name, this.GoLiveModalMod, "GoLiveModal", (_, args, ret) => {
            this.baseFun = ret.type;
            ret.type = (args) => {
                let ret = this.baseFun(args);
                const modalChildren = ret.props.children.props.children[1].props.children;
                let c = modalChildren;
                ret.props.children.props.children[1].props.children = (e) => {
                    let res = c(e);
                    const oldSubmit = res.props.onSubmit;
                    res.props.onSubmit = (args) => {
                        if (settings.useBuildInSoundshare) return oldSubmit(args);
                        if (!audioSource.includes(defaultAudioSource)) {
                            let include = [];

                            if (audioSource.includes(discordAudioSource)) {
                                audioSource = audioSource.filter(source => source !== discordAudioSource);
                                include.push({ "application.process.binary": "Discord", "node.name": "Chromium" });
                            }

                            audioSource.forEach((source) => {
                                let split = source.split(":");
                                let query = {
                                    "node.name": split[0]
                                };
                                if (split.length > 1) {
                                    query["object.id"] = split[1];
                                }
                                include.push(query);
                            });

                            venmic.start_virtmic(include);
                        }
                        else {
                            venmic.start_virtmic_system();
                        }
                        return oldSubmit(args);
                    }
                    return res;
                };
                lastActiveSlide = activeSlide;
                activeSlide = c().props.children[0].props.activeSlide;
                return ret;
            };
        });

        Patcher.after(this.meta.name, this.StreamSettingsPanelMod, "GoLiveModal", (_, args, ret) => {
            const baseFun = ret.props.children[0].props.children[2].type;
            let hook = (args) => {
                let ret = baseFun(args);
                const isScreenshareAudio = ret.props.children.props.value
                if (isScreenshareAudio && activeSlide == 3) {
                    if (ret?.props?.children) {
                        if (!Array.isArray(ret.props.children))
                            ret.props.children = [ret.props.children];

                        if (lastActiveSlide != activeSlide) {
                            audioSource = [defaultAudioSource];
                        }

                        const getOptions = () => {
                            const sources = venmic.list_active_sources().filter(item => item["application.process.binary"] !== "Discord");
                            const options = [{ label: "Entire system", value: defaultAudioSource },
                            { label: "Discord", value: discordAudioSource }
                            ];

                            // Add media sources
                            sources.forEach(source => {
                                options.push({
                                    label: `${source["node.name"]} (${source["media.name"]})`,
                                    value: `${source["node.name"]}:${source["object.id"]}`
                                });
                            });

                            // Add unique node names
                            const uniqueNodeNames = [...new Set(sources.map(source => source["node.name"]))];
                            uniqueNodeNames.forEach(nodeName => {
                                options.push({
                                    label: nodeName,
                                    value: `${nodeName}`
                                });
                            });

                            // Sort options by label, keeping "Default" first
                            const defaultOption = options.shift();
                            options.sort((a, b) => a.label.localeCompare(b.label));
                            options.unshift(defaultOption);
                            return options;
                        }

                        // Add the dropdown to the modal
                        let AudioSourceSelector = () => {
                            const [useBuildInSoundshare, setUseBuildInSoundshare] = React.useState(settings.useBuildInSoundshare);
                            const [options, setOptions] = React.useState(getOptions());

                            return React.createElement("div", {
                                children: [
                                    React.createElement("h1", {
                                        children: "Audio Source",
                                        className: `${TextClasses.h5} ${TextClasses.eyebrow} ${this.FormModalClasses.formItemTitleSlim}`
                                    }),
                                    React.createElement(Components.DropdownMultiple, {
                                        values: audioSource,
                                        options: options,
                                        disabled: useBuildInSoundshare,
                                        onClick: (open) => {
                                            if (open) { setOptions(getOptions()); }
                                        },
                                        onChange: (value, _, values) => {
                                            if (value === defaultAudioSource || values.current.length === 0) {
                                                values.current = [defaultAudioSource];
                                            }
                                            else {
                                                values.current = values.current.filter(v => v !== defaultAudioSource);
                                            }

                                            audioSource = values.current;
                                        }
                                    }),
                                    React.createElement("div", {
                                        style: {
                                            marginTop: "20px",
                                        },
                                        children: [
                                            React.createElement(Components.CheckboxInput, {
                                                value: useBuildInSoundshare,
                                                label: "Use Discord's Soundshare",
                                                onChange: (value) => {
                                                    setUseBuildInSoundshare(value);
                                                    settings.useBuildInSoundshare = value;
                                                    Data.save(this.meta.name, "settings", settings);
                                                },
                                            })],
                                    })
                                ]
                            });
                        }

                        ret.props.children.push(React.createElement(AudioSourceSelector));
                    }
                }
                return ret;
            };
            ret.props.children[0].props.children[2].type = hook;
        });

        Patcher.before(this.meta.name, Utilities, "getAudioPid", (_, args) => {
            if (!settings.useBuildInSoundshare) args[0] = venmic.getVoiceEnginePid();
        });
    }

    onStreamClose = event => {
        const ids = event.streamKey.split(":");
        const owner = ids[ids.length - 1];

        if (owner !== UserStore.getCurrentUser().id) {
            return;
        }

        venmic.stop_virtmic();
    };

    onVoiceChannelSelect = event => {
        if (event.channelId !== null) {
            return;
        }

        venmic.stop_virtmic();
    };

    start() {
        if (!venmic) {
            UI.alert("Error", `Fork of BetterDiscord is required for this plugin to work. You can find it at https://github.com/F1r3d3v/BetterDiscord`);
            Logger.error(this.meta.name, "Fork of BetterDiscord is required for this plugin to work");
            Plugins.disable(this.meta.name);
            return;
        }

        Logger.info(this.meta.name, "Plugin has started. Version: " + this.meta.version);

        try {
            settings = Object.assign({}, defaultSettings, Data.load(this.meta.name, "settings"));
        } catch (err) {
            Logger.warn(this.meta.name, err);
            Logger.info(this.meta.name, "Error parsing JSON. Resetting file to default...");
            fs.rmSync(path.join(Plugins.folder, `${this.meta.name}.config.json`));
            Plugins.reload(this.meta.name);
            Plugins.enable(this.meta.name);
            return;
        }

        this.patch();
    }

    stop() {
        Patcher.unpatchAll(this.meta.name);
        Dispatcher.unsubscribe("VOICE_CHANNEL_SELECT", this.onVoiceChannelSelect);
        Dispatcher.unsubscribe("STREAM_CLOSE", this.onStreamClose);

        Data.save(this.meta.name, "settings", settings);
        Logger.info(this.meta.name, "Plugin has stopped.");
    }
};
