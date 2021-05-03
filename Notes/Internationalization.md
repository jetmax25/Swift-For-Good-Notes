# Internationalization

By default new storyboards are in a folder called Base.Iproj

Need a Iproj folder for every language supported

To Add Localization: Select .xcodeproj file -> info tab -> localization section -> + button

localization - take user facing strings and translate them

Wrap calls to any user strings in `NSLocalizedString("Key", "Comment)`

Run this command in the root directory to generate Localizable.strings file
>`find . -name \*.swift | xargs genstrings -0 .`

File has the structure 
>`"Key" = "Value in current language"`

Be descriptive in both key and comment: for example 
>`NSLocalizedString("alert_invalid_password_title", comment: "Title for alert indicating the user has input an invalid password")`

Try using an enum with some extensions

Change the application language by opening Scheme -> Run -> Options -> Application Language

Use Psudolanguage to fake languages to change text