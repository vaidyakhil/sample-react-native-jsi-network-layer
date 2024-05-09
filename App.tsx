import * as React from 'react';
import {useState} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  NativeModules,
  ScrollView,
  StyleSheet,
} from 'react-native';

import { Skynet } from 'react-native-skynet'

// const __temp = Array.from({length: 20}, (_, index) => index);
// const performExperiment = async (type: 'native' | 'turbo') => {
//   for (const __index of __temp) {
//     const newReponse = await makeNetworkCall(type);
//     appendResponse(newReponse);
//   }
// };

let global_start = null;
let global_end = null;
global.function_set_from_js = response => {
  global_end = Date.now();
  const diff = global_end - global_start;
  console.info(`jsi::callback => ${diff}ms | response type: ${typeof response}`);
};

const COLORS = {
  JSI: '#83fa7d',
  BRIDGE: '#42b3f5'
}

type TimeDiffData = {
  type: 'jsi' | 'bridge';
  roundTrip: number;
}

type ModuleAggregateData = {
  numberOfTrips: number,
  averageTime: number
}

const AggregateData: { jsi: ModuleAggregateData, bridge: ModuleAggregateData } = {
  jsi: {
    numberOfTrips: 0,
    averageTime: 0
  },
  bridge: {
    numberOfTrips: 0,
    averageTime: 0
  }
};

const AggregateDataHolder = ({ aggregateData }: { aggregateData: { jsi: ModuleAggregateData, bridge: ModuleAggregateData } }) => {
  return (
    <View style={{ backgroundColor: '#FFFFFF', paddingVertical: 8, paddingHorizontal: 8, rowGap: 8, marginVertical: 2 }}>
      <Text
        style={{ ...styles.dataStrip, backgroundColor: COLORS.JSI }}>
        JSI Avg Time => {aggregateData['jsi'].averageTime} in {aggregateData['jsi'].numberOfTrips} trips:{' '}
      </Text>
      <Text
        style={{ ...styles.dataStrip, backgroundColor: COLORS.BRIDGE }}>
        Bridge Avg Time => {aggregateData['bridge'].averageTime} in {aggregateData['bridge'].numberOfTrips} trips:{' '}
      </Text>
    </View>
  );
};

const makeNetworkCallViaJSI = async () => {
  return await Skynet.sendRequest();
}

const makeNetworkCallViaFetch = async () => {
  return await fetch('https://metrics.cocoapods.org/api/v1/pods/CocoaAsyncSocket');
}

const getFunctionWithMeasures = (originalApi: Function) => {
  return async (...args) => {
    const start = Date.now();
    const originalResponse = await originalApi(...args);
    const end = Date.now();
    const diff = end - start;

    if (__DEV__) {
      console.info(`${originalApi.typeOfCommLayer}: ${diff}ms | response type: ${typeof originalResponse}`);
    }

    return {
      response: originalResponse,
      measure: {
        timeTaken: diff
      }
    }
  }
}


const updateAggregateData = (type: 'jsi' | 'bridge', newTimeDiff: number) => {
  const updatedModuleData = {
    numberOfTrips: AggregateData[type].numberOfTrips + 1,
    averageTime: (AggregateData[type].averageTime*AggregateData[type].numberOfTrips + newTimeDiff)/(AggregateData[type].numberOfTrips + 1)
  }
  AggregateData[type] = updatedModuleData;
}

const App = () => {
  const [timeDiffs, setTimeDiffs] = useState<TimeDiffData[]>([]);

  const appendResponse = (timeDiffs: TimeDiffData) => {
    updateAggregateData(timeDiffs.type, timeDiffs.roundTrip);
    setTimeDiffs(prevTimeDiffs => [...prevTimeDiffs, timeDiffs]);
  };

  const ButtonsHolder = () => {
    const jsiButtonClick = async () => {
      makeNetworkCallViaJSI.typeOfCommLayer = 'jsi';
      const callApi = getFunctionWithMeasures(makeNetworkCallViaJSI);

      const wrappedResponse = await callApi()
      appendResponse({ type: 'jsi', roundTrip: wrappedResponse.measure.timeTaken })
    }

    const bridgeButtonClick = async () => {
      makeNetworkCallViaFetch.typeOfCommLayer = 'bridge';
      const callApi = getFunctionWithMeasures(makeNetworkCallViaFetch);

      const wrappedResponse = await callApi()
      appendResponse({ type: 'bridge', roundTrip: wrappedResponse.measure.timeTaken })
    }

    const jsiCallbackButtonClick = async () => {
      global_start = Date.now();
      Skynet.makeRequest();
    }

    return (
      <View style={styles.buttonHolder}>
        <TouchableOpacity
          onPress={jsiButtonClick}
          style={[styles.button, { backgroundColor: COLORS.JSI }]}>
          <Text>JSI:Promise</Text>
        </TouchableOpacity>
{/* 
        <TouchableOpacity
          onPress={jsiCallbackButtonClick}
          style={[styles.button, { backgroundColor: COLORS.JSI }]}>
          <Text>JSI:Callback</Text>
        </TouchableOpacity> */}

        <TouchableOpacity
          onPress={bridgeButtonClick}
          style={[styles.button, { backgroundColor: COLORS.BRIDGE }]}>
          <Text>Bridge Module</Text>
        </TouchableOpacity>
      </View>
    );
  };

  return (
    <View
      style={{
        flex: 1,
        paddingVertical: 40
      }}>

      <AggregateDataHolder aggregateData={AggregateData} />

      <ScrollView>
        {timeDiffs.map(({type, roundTrip}, index) => (
          <View
            style={[styles.dataStrip, { backgroundColor: type === 'jsi' ? COLORS.JSI : COLORS.BRIDGE }]}
            key={`roundTrip-${index}`}>
            <Text>{type.toUpperCase()}: </Text>
            <Text style={{ fontWeight: 'bold' }}>{roundTrip}ms</Text>
          </View>
        ))}
      </ScrollView>
      <ButtonsHolder />
    </View>
  );
};

const styles = StyleSheet.create({
  dataStrip: {
    backgroundColor: '#83fa7d',
    padding: 8,
    flexDirection: 'row',
    marginVertical: 1,
  },
  buttonHolder: {
    backgroundColor: '#bbbbbb',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 16,
    paddingVertical: 12,
  },
  button: {
    padding: 16,
    backgroundColor: '#83fa7d',
  }
});

export default App;
