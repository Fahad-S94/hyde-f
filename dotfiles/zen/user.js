//PLACE IN PROFILE FOLDER, NOT CHROME FOLDER
// Enable custom CSS stylesheets
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("dom.disable_beforeunload", true);
user_pref("browser.tabs.min_inactive_duration_before_unload", 300000);
user_pref("browser.tabs.searchclipboardfor.middleclick", false);
user_pref("browser.tabs.insertAfterCurrent", true);

// Zen compact view settings
user_pref("zen.view.compact.hide-toolbar", true);
user_pref("zen.view.compact.show-background-tab-toast", false);
user_pref("zen.view.compact.enable-at-startup", true);
user_pref("zen.theme.content-element-separation", 0);

// Zen interface customization
user_pref("zen.view.experimental-no-window-controls", true);
// user_pref("zen.view.use-single-toolbar", true);
