// @flow

import React from 'react';
import { Provider as PaperProvider } from 'react-native-paper';
import { AppRegistry } from 'react-native';
import { name as appName } from './app.json';
import App from './App';
import theme from './theme';

let Main = () => (
  <PaperProvider theme={theme}>
    <App />
  </PaperProvider>
);

AppRegistry.registerComponent(appName, () => Main);
