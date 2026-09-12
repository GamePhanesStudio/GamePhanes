Fill in the method bodies of `LocalizationPlugin`, a Paper plugin for a locale-aware settings inventory.

Create two property files under `src/main/resources/lang/`: one for English and one for Russian. Both must define at least `title` and `save` keys. The Russian file must have `title=Настройки` and `save=Сохранить`.

Starting a settings session should set the active locale to English, open a nine-slot inventory named "Settings" for every online player, place items at slots 4 and 8 labeled with the appropriate translations, and return success. It should fail if a session is already running or no players are online. Switching the locale should swap the active language and re-render the label on every open inventory, returning failure for an unstarted session, unsupported locale, or resource load failure — locale matching should be case-insensitive. Looking up a translation key should return the value for the current locale, falling back to "missing" for a null key, unknown key, or unstarted session. Rendering the settings summary should return a string in the format `locale:title-value:save-value`, or "missing" when the session isn't running.

When a player closes their settings inventory, remove their view from tracking. Resetting should close and clear all tracked inventories, reset the started flag, and wipe the loaded locale and translations.

Build with `/app/build.sh`. Submit Java sources under `src/main/java` and resource files under `src/main/resources`.