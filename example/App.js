// @flow

import * as React from 'react';
import { Appbar, List, TouchableRipple, Snackbar } from 'react-native-paper';
import * as RNPermissions from 'react-native-permissions';
import type { Permission, PermissionStatus } from 'react-native-permissions';
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
const permissionsValues = Object.values(platformPermissions);

const statusColors: { [PermissionStatus]: string } = {
  granted: '#43a047',
  denied: '#ff9800',
  never_ask_again: '#e53935',
  unavailable: '#cfd8dc',
};

const statusIcons: { [PermissionStatus]: string } = {
  granted: 'check-circle',
  denied: 'error',
  never_ask_again: 'cancel',
  unavailable: 'lens',
};

type AppStateType = 'active' | 'background' | 'inactive';

type Props = {};

// RNPermissions.checkMultiple([
//   RNPermissions.ANDROID_PERMISSIONS.ACCESS_FINE_LOCATION,
//   RNPermissions.ANDROID_PERMISSIONS.PROCESS_OUTGOING_CALLS,
// ]).then(result => {
//   console.log(result);
// });

type State = {|
  snackBarVisible: boolean,
  watchAppState: boolean,
  statuses: { [Permission]: PermissionStatus },
|};

export default class App extends React.Component<Props, State> {
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
    // $FlowFixMe
    RNPermissions.checkMultiple(permissionsValues)
      .then(statuses => {
        // $FlowFixMe
        this.setState({ statuses });
      })
      .catch(error => {
        console.error(error);
      });
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
            {permissionsValues.map(value => {
              const key = permissionsKeys[permissionsValues.indexOf(value)];
              const status = this.state.statuses[value];

              return (
                <TouchableRipple
                  key={key}
                  disabled={
                    status === RNPermissions.RESULTS.UNAVAILABLE ||
                    status === RNPermissions.RESULTS.NEVER_ASK_AGAIN
                  }
                  onPress={() => {
                    // $FlowFixMe
                    RNPermissions.request(platformPermissions[key]).then(
                      result => {
                        this.setState(prevState => ({
                          ...prevState,
                          statuses: {
                            ...prevState.statuses,
                            [value]: result,
                          },
                        }));
                      },
                    );
                  }}
                >
                  <List.Item
                    title={key}
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
