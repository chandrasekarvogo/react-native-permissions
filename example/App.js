// @flow

import * as React from 'react';
import { Appbar, List, TouchableRipple, Snackbar } from 'react-native-paper';
import * as RNPermissions from 'react-native-permissions';
import type { PermissionStatus } from 'react-native-permissions';
import theme from './theme';

import {
  AppState,
  Platform,
  StatusBar,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native';

const { PERMISSIONS } = RNPermissions;
// we remove siri from the example since it needs a certificate
const { SIRI, ...IOS_PERMISSIONS } = PERMISSIONS.IOS;

const platformPermissions =
  Platform.OS === 'android' ? PERMISSIONS.ANDROID : IOS_PERMISSIONS;

const permissionsKeys = Object.keys(platformPermissions);
// $FlowFixMe
const permissionsValues: string[] = Object.values(platformPermissions);

const statusColors: { [PermissionStatus]: string } = {
  unavailable: '#cfd8dc',
  denied: '#ff9800',
  granted: '#43a047',
  blocked: '#e53935',
};

const statusIcons: { [PermissionStatus]: string } = {
  unavailable: 'lens',
  denied: 'error',
  granted: 'check-circle',
  blocked: 'cancel',
};

type AppStateType = 'active' | 'background' | 'inactive';

type State = {|
  snackBarVisible: boolean,
  watchAppState: boolean,
  statuses: { [permisson: string]: PermissionStatus },
|};

export default class App extends React.Component<{}, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      snackBarVisible: false,
      watchAppState: false,
      statuses: {},
    };

    setTimeout(() => {
      this.checkAllPermissions();
    }, 2000);
  }

  componentDidMount() {
    AppState.addEventListener('change', this.onAppStateChange);
  }

  componentWillUnmount() {
    AppState.removeEventListener('change', this.onAppStateChange);
  }

  checkAllPermissions = () => {
    RNPermissions.checkMultiple(permissionsValues)
      .then(statuses => this.setState({ statuses }))
      .catch(error => console.error(error));
  };

  onAppStateChange = (nextAppState: AppStateType) => {
    if (this.state.watchAppState && nextAppState === 'active') {
      this.setState({
        snackBarVisible: true,
        watchAppState: false,
      });

      setTimeout(() => {
        // @TODO don't fire setState on unmounted component
        this.setState({ snackBarVisible: false });
      }, 3000);
    }
  };

  render() {
    return (
      <View style={styles.container}>
        <StatusBar
          backgroundColor={theme.colors.primary}
          barStyle="light-content"
        />

        <Appbar.Header>
          <Appbar.Content
            title="react-native-permissions"
            subtitle="Example application"
          />

          <Appbar.Action
            icon="settings-applications"
            onPress={() => {
              this.setState({ watchAppState: true }, () => {
                RNPermissions.openSettings();
              });
            }}
          />
        </Appbar.Header>

        <ScrollView>
          <List.Section>
            {permissionsValues.map(permissionValue => {
              const permissionKey =
                permissionsKeys[permissionsValues.indexOf(permissionValue)];
              const status = this.state.statuses[permissionValue];

              return (
                <TouchableRipple
                  key={permissionKey}
                  disabled={
                    status === RNPermissions.RESULTS.UNAVAILABLE ||
                    status === RNPermissions.RESULTS.BLOCKED
                  }
                  onPress={() => {
                    RNPermissions.request(
                      // $FlowFixMe
                      platformPermissions[permissionKey],
                    ).then(result => {
                      this.setState(prevState => ({
                        ...prevState,
                        statuses: {
                          ...prevState.statuses,
                          [permissionValue]: result,
                        },
                      }));
                    });
                  }}
                >
                  <List.Item
                    title={permissionKey}
                    description={status}
                    right={() => (
                      <List.Icon
                        color={statusColors[status]}
                        icon={statusIcons[status]}
                      />
                    )}
                  />
                </TouchableRipple>
              );
            })}
          </List.Section>
        </ScrollView>

        <Snackbar
          onDismiss={() => this.setState({ snackBarVisible: false })}
          visible={this.state.snackBarVisible}
        >
          Welcome back ! Refreshing permissions…
        </Snackbar>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
});
