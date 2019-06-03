// @flow

import React from 'react';
import { Appbar, List, TouchableRipple } from 'react-native-paper';
import * as RNPermissions from 'react-native-permissions';
import type { PermissionStatus } from 'react-native-permissions';
import theme from './theme';

import {
  RefreshControl,
  SafeAreaView,
  Platform,
  StatusBar,
  FlatList,
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

type State = {|
  refreshing: boolean,
  statuses: { [permisson: string]: PermissionStatus },
|};

export default class App extends React.Component<{}, State> {
  state = {
    refreshing: false,
    statuses: {},
  };

  checkPermissions = (refreshing: boolean) => {
    this.setState({ refreshing, statuses: {} }, () => {
      RNPermissions.checkMultiple(permissionsValues)
        .then(statuses => this.setState({ refreshing: false, statuses }))
        .catch(error => console.error(error));
    });
  };

  componentDidMount() {
    this.checkPermissions(false);
  }

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
            onPress={() => this.checkPermissions(false)}
            icon="refresh"
          />

          <Appbar.Action
            onPress={RNPermissions.openSettings}
            icon="settings-applications"
          />
        </Appbar.Header>

        <FlatList
          ListFooterComponent={<SafeAreaView style={{ flex: 0 }} />}
          data={permissionsValues}
          keyExtractor={item =>
            permissionsKeys[permissionsValues.indexOf(item)]
          }
          refreshControl={
            <RefreshControl
              onRefresh={() => this.checkPermissions(true)}
              refreshing={this.state.refreshing}
            />
          }
          renderItem={({ item }) => {
            const status = this.state.statuses[item];
            const key = permissionsKeys[permissionsValues.indexOf(item)];

            return (
              <TouchableRipple
                disabled={
                  status === RNPermissions.RESULTS.UNAVAILABLE ||
                  status === RNPermissions.RESULTS.BLOCKED
                }
                onPress={() => {
                  RNPermissions.request(
                    // $FlowFixMe
                    platformPermissions[key],
                  ).then(result => {
                    this.setState(prevState => ({
                      ...prevState,
                      statuses: { ...prevState.statuses, [item]: result },
                    }));
                  });
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
          }}
        />
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
