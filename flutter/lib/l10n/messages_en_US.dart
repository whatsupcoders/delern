// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en_US';

  static m0(numberOfCards) => "${numberOfCards} to learn";

  static m1(date) =>
      "Next card to learn is suggested at ${date}. Would you like to continue learning anyway?";

  static m2(url) => "Could not launch url ${url}";

  static m3(number) => "Cards in the deck: ${number}";

  static m4(number) => "Watched: ${number}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "accountExistUserWarning": MessageLookupByLibrary.simpleMessage(
            "You already have an account, please sign in with your credentials. All your data, that was created anonymously, will be lost. Would you like to continue?"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addCardTooltip": MessageLookupByLibrary.simpleMessage("Add Card"),
        "addCardsDeckMenu": MessageLookupByLibrary.simpleMessage("Add Cards"),
        "addDeckTooltip": MessageLookupByLibrary.simpleMessage("Add Deck"),
        "anonymous": MessageLookupByLibrary.simpleMessage("Anonymous"),
        "appLogoName":
            MessageLookupByLibrary.simpleMessage("Delern Flashcards"),
        "appNotInstalledSharingDeck": MessageLookupByLibrary.simpleMessage(
            "This user hasn\'t installed Delern yet. Do you want to sent an invite?"),
        "backSideHint": MessageLookupByLibrary.simpleMessage("Back side"),
        "basicDeckType": MessageLookupByLibrary.simpleMessage("Basic"),
        "canEdit": MessageLookupByLibrary.simpleMessage("Can Edit"),
        "canView": MessageLookupByLibrary.simpleMessage("Can View"),
        "cardAddedUserMessage":
            MessageLookupByLibrary.simpleMessage("Card was added"),
        "cardAndReversedAddedUserMessage": MessageLookupByLibrary.simpleMessage(
            "Card and reversed card were added"),
        "cardDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Card was deleted"),
        "cardsToLearnLabel": m0,
        "continueAnonymously":
            MessageLookupByLibrary.simpleMessage("Continue Anonymously"),
        "continueEditingQuestion": MessageLookupByLibrary.simpleMessage(
            "You have unsaved changes. Would you like to continue editing?"),
        "continueLearningQuestion": m1,
        "couldNotLaunchUrl": m2,
        "createDeckTooltip":
            MessageLookupByLibrary.simpleMessage("Create deck"),
        "deck": MessageLookupByLibrary.simpleMessage("Deck"),
        "deckDeletedUserMessage":
            MessageLookupByLibrary.simpleMessage("Deck was deleted"),
        "deckSettingsTooltip":
            MessageLookupByLibrary.simpleMessage("Settings of deck"),
        "deckType": MessageLookupByLibrary.simpleMessage("Deck Type"),
        "decksIntroDescription": MessageLookupByLibrary.simpleMessage(
            "Create decks with flashcards"),
        "decksIntroTitle": MessageLookupByLibrary.simpleMessage("Create Decks"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteCardQuestion": MessageLookupByLibrary.simpleMessage(
            "Do you want to delete this card?"),
        "deleteCardTooltip":
            MessageLookupByLibrary.simpleMessage("Delete card"),
        "deleteDeckButton": MessageLookupByLibrary.simpleMessage("Delete Deck"),
        "deleteDeckOwnerAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "The deck, all cards and learning history will be removed.\n\nIf you have shared this deck with other users, it will also be removed from all users it is shared with. Do you want to delete the deck?"),
        "deleteDeckWriteReadAccessQuestion": MessageLookupByLibrary.simpleMessage(
            "The deck will be removed from your account only, all cards and learning history will remain with the owner and other users. Do you want to delete the deck?"),
        "discard": MessageLookupByLibrary.simpleMessage("Discard"),
        "doNotKnowCardTooltip":
            MessageLookupByLibrary.simpleMessage("I don\'t know"),
        "doNotNeedFeaturesText": MessageLookupByLibrary.simpleMessage(
            "I do not want any of these features"),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editCardTooltip": MessageLookupByLibrary.simpleMessage("Edit card"),
        "editCardsDeckMenu": MessageLookupByLibrary.simpleMessage("Edit Cards"),
        "emailAddressHint":
            MessageLookupByLibrary.simpleMessage("Email address"),
        "emptyCardsList":
            MessageLookupByLibrary.simpleMessage("Add your cards"),
        "emptyDecksList":
            MessageLookupByLibrary.simpleMessage("Add your decks"),
        "emptyUserSharingList":
            MessageLookupByLibrary.simpleMessage("Share your deck"),
        "errorUserMessage": MessageLookupByLibrary.simpleMessage("Error: "),
        "flip": MessageLookupByLibrary.simpleMessage("flip"),
        "frontSideHint": MessageLookupByLibrary.simpleMessage("Front side"),
        "germanDeckType": MessageLookupByLibrary.simpleMessage("German"),
        "installEmailApp":
            MessageLookupByLibrary.simpleMessage("Please install Email App"),
        "intervalLearning": MessageLookupByLibrary.simpleMessage("Interval"),
        "intervalLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Start learning cards ordered for interval learning"),
        "inviteToAppMessage": MessageLookupByLibrary.simpleMessage(
            "I invite you to install Delern, a spaced repetition learning app, which will allow you to learn quickly and easily!\n\nProceed to install it from:\nGoogle Play: https://play.google.com/store/apps/details?id=org.dasfoo.delern\nApp Store: https://itunes.apple.com/us/app/delern/id1435734822\n\nAfter install, follow Delern latest news on:\nFacebook: https://fb.me/das.delern\nLinkedIn: https://www.linkedin.com/company/delern\nVK: https://vk.com/delern\nTwitter: https://twitter.com/dasdelern"),
        "knowCardTooltip": MessageLookupByLibrary.simpleMessage("I know"),
        "learnIntroDescription": MessageLookupByLibrary.simpleMessage(
            "Learn in any place and offline as well"),
        "learnIntroTitle": MessageLookupByLibrary.simpleMessage("Learn"),
        "learning": MessageLookupByLibrary.simpleMessage("Learning"),
        "listOFDecksScreenTitle":
            MessageLookupByLibrary.simpleMessage("List of decks"),
        "markdown": MessageLookupByLibrary.simpleMessage("Markdown"),
        "menuTooltip": MessageLookupByLibrary.simpleMessage("Menu"),
        "navigationDrawerAbout": MessageLookupByLibrary.simpleMessage("About"),
        "navigationDrawerCommunicateGroup":
            MessageLookupByLibrary.simpleMessage("Communicate"),
        "navigationDrawerContactUs":
            MessageLookupByLibrary.simpleMessage("Contact Us"),
        "navigationDrawerInviteFriends":
            MessageLookupByLibrary.simpleMessage("Invite Friends"),
        "navigationDrawerSignIn":
            MessageLookupByLibrary.simpleMessage("Sign In"),
        "navigationDrawerSignOut":
            MessageLookupByLibrary.simpleMessage("Sign Out"),
        "navigationDrawerSupportDevelopment":
            MessageLookupByLibrary.simpleMessage("Support Development"),
        "no": MessageLookupByLibrary.simpleMessage("no"),
        "noAccess": MessageLookupByLibrary.simpleMessage("No access"),
        "noAddingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "You cannot add cards with a read access."),
        "noDeletingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "You cannot delete card with a read access."),
        "noEditingWithReadAccessUserMessage":
            MessageLookupByLibrary.simpleMessage(
                "You cannot edit card with a read access."),
        "noSharingAccessUserMessage": MessageLookupByLibrary.simpleMessage(
            "Only owner of deck can share it."),
        "numberOfCards": m3,
        "offlineProfileTooltip":
            MessageLookupByLibrary.simpleMessage("Profile (you are offline)"),
        "offlineUserMessage": MessageLookupByLibrary.simpleMessage(
            "You are offline, please try it later"),
        "other": MessageLookupByLibrary.simpleMessage("other"),
        "owner": MessageLookupByLibrary.simpleMessage("Owner"),
        "peopleLabel": MessageLookupByLibrary.simpleMessage("People"),
        "profileTooltip": MessageLookupByLibrary.simpleMessage("Profile"),
        "reversedCardLabel":
            MessageLookupByLibrary.simpleMessage("Add reversed card"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveChangesQuestion": MessageLookupByLibrary.simpleMessage(
            "Do you want to save changes?"),
        "scrollToStartLabel":
            MessageLookupByLibrary.simpleMessage("Scroll to the beginning"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Search..."),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "serverUnavailableUserMessage": MessageLookupByLibrary.simpleMessage(
            "Server temporarily unavailable, please try again later"),
        "settingsDeckMenu": MessageLookupByLibrary.simpleMessage("Settings"),
        "shareDeckMenu": MessageLookupByLibrary.simpleMessage("Share"),
        "shareDeckTooltip": MessageLookupByLibrary.simpleMessage("Share deck"),
        "shareIntroDescription": MessageLookupByLibrary.simpleMessage(
            "Share decks with friends and colleagues to learn together"),
        "shareIntroTitle": MessageLookupByLibrary.simpleMessage("Share decks"),
        "signInWithGoogle":
            MessageLookupByLibrary.simpleMessage("Sign in with Google"),
        "skip": MessageLookupByLibrary.simpleMessage("Skip"),
        "splashScreenFeatures": MessageLookupByLibrary.simpleMessage(
            "Data and progress are saved in the Cloud\nData and progress are synchronized across all your devices\nShare cards with your friends and colleagues"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage(
            "Please tell us what we can do to make your experience with Delern better!\n\nIf you have any questions or suggestions please contact us:\n[delern@dasfoo.org](mailto:delern@dasfoo.org)\n\nFollow latest news on:\n\n- [Facebook](https://fb.me/das.delern)\n- [Twitter](https://twitter.com/dasdelern)\n- [LinkedIn](https://www.linkedin.com/company/delern)\n- [VK](https://vk.com/delern)\n\nTo see the source code for this app, please visit the [Delern GitHub repo](https://github.com/dasfoo/delern).\n      "),
        "swissDeckType": MessageLookupByLibrary.simpleMessage("Swiss"),
        "unknownDeckType": MessageLookupByLibrary.simpleMessage("Unknown"),
        "viewLearning": MessageLookupByLibrary.simpleMessage("View"),
        "viewLearningTooltip": MessageLookupByLibrary.simpleMessage(
            "Start learning all cards in any order"),
        "watchedCards": m4,
        "whoHasAccessLabel":
            MessageLookupByLibrary.simpleMessage("Who has access"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
