// @flow

import React from 'react';
import { Appbar, List, TouchableRipple } from 'react-native-paper';
import * as RNPermissions from 'react-native-permissions';
import type { PermissionStatus } from 'react-native-permissions';
import theme from './theme';

import {
  FlatList,
  Platform,
  RefreshControl,
  StatusBar,
  SafeAreaView,
  View,
} from 'react-native';

const { PERMISSIONS } = RNPermissions;
const { SIRI, ...PERMISSIONS_IOS } = PERMISSIONS.IOS; // remove siri (certificate required)

const PLATFORM_PERMISSIONS = Platform.select({
  ios: PERMISSIONS_IOS,
  android: PERMISSIONS.ANDROID,
  default: {},
});

// $FlowFixMe
const PERMISSIONS_VALUES: string[] = Object.values(PLATFORM_PERMISSIONS);
const PERMISSIONS_KEYS = Object.keys(PLATFORM_PERMISSIONS);

const colors: { [PermissionStatus]: string } = {
  unavailable: '#cfd8dc',
  denied: '#ff9800',
  granted: '#43a047',
  blocked: '#e53935',
};

const icons: { [PermissionStatus]: string } = {
  unavailable: 'lens',
  denied: 'error',
  granted: 'check-circle',
  blocked: 'cancel',
};

let PermissionRow = ({
  name,
  disabled,
  status,
  onPress,
}: {
  name: string,
  status: PermissionStatus,
  disabled: boolean,
  onPress: (name: string) => void,
}) => (
  <TouchableRipple disabled={disabled} onPress={onPress}>
    <List.Item
      right={() => <List.Icon color={colors[status]} icon={icons[status]} />}
      title={name}
      description={status}
    />
  </TouchableRipple>
);

type State = {|
  statuses: PermissionStatus[],
  refreshing: boolean,
|};

export default class App extends React.Component<{}, State> {
  state = {
    statuses: [],
    refreshing: false,
  };

  check = () =>
    Promise.all(PERMISSIONS_VALUES.map(_ => RNPermissions.check(_)))
      .then(statuses => this.setState({ statuses }))
      .catch(error => console.error(error));

  refresh = () =>
    this.setState({ refreshing: true, statuses: [] }, () => {
      this.check().finally(() => this.setState({ refreshing: false }));
    });

  componentDidMount() {
    this.check();
  }

  render() {
    return (
      <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
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
            onPress={RNPermissions.openSettings}
            icon="settings-applications"
          />
        </Appbar.Header>

        <FlatList
          ListFooterComponent={<SafeAreaView style={{ flex: 0 }} />}
          data={PERMISSIONS_KEYS}
          keyExtractor={item => item}
          refreshControl={
            <RefreshControl
              refreshing={this.state.refreshing}
              onRefresh={this.refresh}
            />
          }
          renderItem={({ item, index }) => {
            const value = PERMISSIONS_VALUES[index];
            const status = this.state.statuses[index];

            return (
              <PermissionRow
                status={status}
                name={item}
                disabled={
                  status === RNPermissions.RESULTS.UNAVAILABLE ||
                  status === RNPermissions.RESULTS.BLOCKED
                }
                onPress={() => {
                  RNPermissions.request(value).then(result => {
                    const statuses = [...this.state.statuses];
                    statuses[index] = result;
                    this.setState({ statuses });
                  });
                }}
              />
            );
          }}
        />
      </View>
    );
  }
}
