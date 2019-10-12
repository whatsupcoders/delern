import 'dart:async';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/routes.dart';
import 'package:delern_flutter/views/decks_list/developer_menu.dart';
import 'package:delern_flutter/views/helpers/email_launcher.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/send_invite.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:pedantic/pedantic.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String versionCode;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) => setState(() {
          versionCode = packageInfo.version;
        }));
  }

  List<Widget> _buildUserButtons(User user) {
    final list = <Widget>[
      ListTile(
        title: Text(
          localizations.of(context).navigationDrawerCommunicateGroup,
          style: app_styles.navigationDrawerGroupText,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.contact_mail),
        title: Text(localizations.of(context).navigationDrawerInviteFriends),
        onTap: () {
          sendInvite(context);
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.live_help),
        title: Text(localizations.of(context).navigationDrawerContactUs),
        onTap: () async {
          Navigator.pop(context);
          await launchEmail(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.developer_board),
        title:
            Text(localizations.of(context).navigationDrawerSupportDevelopment),
        onTap: () {
          Navigator.pop(context);
          openSupportDevelopmentScreen(context);
        },
      ),
      const Divider(height: 1),
      AboutListTile(
        icon: const Icon(Icons.perm_device_information),
        applicationIcon: Image.asset('images/ic_launcher.png'),
        applicationVersion: versionCode,
        applicationLegalese: 'GNU General Public License v3.0',
        child: Text(localizations.of(context).navigationDrawerAbout),
      ),
    ];

    final signInOutWidget = ListTile(
      leading: const Icon(Icons.perm_identity),
      title: Text(user.isAnonymous
          ? localizations.of(context).navigationDrawerSignIn
          : localizations.of(context).navigationDrawerSignOut),
      onTap: () {
        if (user.isAnonymous) {
          unawaited(_promoteAnonymous(context));
        } else {
          unawaited(Auth.instance.signOut());
          Navigator.pop(context);
        }
      },
    );

    if (user.isAnonymous) {
      list..insert(0, signInOutWidget)..insert(1, const Divider(height: 1));
    } else {
      list..add(const Divider(height: 1))..add(signInOutWidget);
    }

    assert(() {
      list.addAll(buildDeveloperMenu(context));
      return true;
    }());

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUserWidget.of(context).user;

    final accountName = user.displayName ?? localizations.of(context).anonymous;

    return Drawer(
      child: ListView(
          // Remove any padding from the ListView.
          // https://flutter.io/docs/cookbook/design/drawer
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(accountName),
              accountEmail: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (user.email != null) Text(user.email),
                      ...user.providers.map(_buildProviderImage),
                    ],
                  )),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user.photoUrl == null
                    ? const AssetImage('images/anonymous.jpg')
                    : NetworkImage(user.photoUrl),
              ),
            ),
            ..._buildUserButtons(user),
          ]),
    );
  }

  Widget _buildProviderImage(SignInProvider provider) {
    switch (provider) {
      // TODO(dotdoom): add more providers here #944.
      case SignInProvider.google:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset('images/google_sign_in.png', height: 18),
        );
      default:
        unawaited(error_reporting.report(
            'NavigationDrawer', 'Unknown provider: $provider', null));
        // For "SignInProvider.facebook" returns Text("facebook").
        return Text(provider
            .toString()
            .substring(provider.runtimeType.toString().length + 1));
    }
  }

  Future<void> _promoteAnonymous(BuildContext context) async {
    unawaited(logPromoteAnonymous());
    try {
      await Auth.instance.signIn(SignInProvider.google);
    } on PlatformException catch (_) {
      // TODO(ksheremet): Merge data
      unawaited(logPromoteAnonymousFail());
      final signIn = await showSaveUpdatesDialog(
          context: context,
          changesQuestion: localizations.of(context).accountExistUserWarning,
          yesAnswer: localizations.of(context).navigationDrawerSignIn,
          noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
      if (signIn) {
        // Sign out of Firebase but retain the account that has been picked by
        // user.
        await Auth.instance.signOut();
        unawaited(Auth.instance
            .signIn(SignInProvider.google, forceAccountPicker: false));
      } else {
        Navigator.of(context).pop();
      }
    }
  }
}
