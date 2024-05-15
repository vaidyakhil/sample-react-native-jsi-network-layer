import * as React from 'react';
import {useState} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

import { Skynet } from 'react-native-skynet'
import { JsiHttp } from 'react-native-jsi-cpr';
const cprHttpClient = new JsiHttp({
  baseUrl: 'https://metrics.cocoapods.org',
  timeout: 1000,
}, __DEV__)

let global_start = null;
let global_end = null;
global.function_set_from_js = response => {
  global_end = Date.now();
  const diff = global_end - global_start;
  console.info(`jsi::callback => ${diff}ms | response type: ${typeof response}`);
};


const MODULE_TYPES = ['jsi', 'cpr', 'bridge'];
const COLORS = {
  jsi: '#83fa7d',
  bridge: '#42b3f5',
  cpr: '#fcf803'
}

type TimeDiffData = {
  type: 'jsi' | 'bridge' | 'cpr';
  roundTrip: number;
}

type ModuleAggregateData = {
  numberOfTrips: number,
  averageTime: number
}

const AggregateData: { jsi: ModuleAggregateData, bridge: ModuleAggregateData, cpr: ModuleAggregateData } = {
  jsi: {
    numberOfTrips: 0,
    averageTime: 0
  },
  cpr: {
    numberOfTrips: 0,
    averageTime: 0
  },
  bridge: {
    numberOfTrips: 0,
    averageTime: 0
  }
};

const AggregateDataHolder = ({ aggregateData }: { aggregateData: { jsi: ModuleAggregateData, bridge: ModuleAggregateData, cpr: ModuleAggregateData } }) => {
  return (
    <View style={{ backgroundColor: '#FFFFFF', paddingVertical: 8, paddingHorizontal: 8, rowGap: 8, marginVertical: 2 }}>
      <Text
        style={{ ...styles.dataStrip, backgroundColor: COLORS.jsi }}>
        jsi:Custom Avg Time => {aggregateData['jsi'].averageTime} in {aggregateData['jsi'].numberOfTrips} trips:{' '}
      </Text>
      <Text
        style={{ ...styles.dataStrip, backgroundColor: COLORS.cpr }}>
        jsi:cpr Avg Time => {aggregateData['cpr'].averageTime} in {aggregateData['cpr'].numberOfTrips} trips:{' '}
      </Text>
      <Text
        style={{ ...styles.dataStrip, backgroundColor: COLORS.bridge }}>
        Bridge Avg Time => {aggregateData['bridge'].averageTime} in {aggregateData['bridge'].numberOfTrips} trips:{' '}
      </Text>
    </View>
  );
};

  const makeNetworkCallViaJSI = async () => {
    return await Skynet.sendRequest();
  }

  const makeNetworkCallViaCPR = async () => {
    return await cprHttpClient.get('api/v1/pods/CocoaAsyncSocket');
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


const updateAggregateData = (type: 'jsi' | 'bridge' | 'cpr', newTimeDiff: number) => {
  const updatedModuleData = {
    numberOfTrips: AggregateData[type].numberOfTrips + 1,
    averageTime: (AggregateData[type].averageTime*AggregateData[type].numberOfTrips + newTimeDiff)/(AggregateData[type].numberOfTrips + 1)
  }
  AggregateData[type] = updatedModuleData;
}

function delay(time) {
  return new Promise(resolve => setTimeout(resolve, time));
}

const App = () => {
  const [timeDiffs, setTimeDiffs] = useState<TimeDiffData[]>([]);
  const [dummy, triggerRender] = useState(false);
  const moduleUnderExperiment = React.useRef(MODULE_TYPES[0]);

  const appendResponse = (timeDiffs: TimeDiffData) => {
    updateAggregateData(timeDiffs.type, timeDiffs.roundTrip);
    triggerRender((prev) => !prev);
  };

  React.useEffect(() => {

    const runExperiment = async () => {
      const jsiButtonClick = async () => {
        makeNetworkCallViaJSI.typeOfCommLayer = 'jsi';
        const callApi = getFunctionWithMeasures(makeNetworkCallViaJSI);
  
        const wrappedResponse = await callApi()
        appendResponse({ type: 'jsi', roundTrip: wrappedResponse.measure.timeTaken })
      }
  
      const cprButtonClick = async () => {
        makeNetworkCallViaCPR.typeOfCommLayer = 'cpr';
        const callApi = getFunctionWithMeasures(makeNetworkCallViaCPR);
  
        const wrappedResponse = await callApi()
        appendResponse({ type: 'cpr', roundTrip: wrappedResponse.measure.timeTaken })
      }
  
      const bridgeButtonClick = async () => {
        makeNetworkCallViaFetch.typeOfCommLayer = 'bridge';
        const callApi = getFunctionWithMeasures(makeNetworkCallViaFetch);
  
        const wrappedResponse = await callApi()
        appendResponse({ type: 'bridge', roundTrip: wrappedResponse.measure.timeTaken })
      }

      const moduleCallMap = {
        jsi: jsiButtonClick,
        cpr: cprButtonClick,
        bridge: bridgeButtonClick
      };

      await delay(5000);

      for (let idx = 0; idx < MODULE_TYPES.length; idx++) {
          moduleUnderExperiment.current = MODULE_TYPES[idx];
          let iter = 0;
          while(iter < 600) {
            await moduleCallMap[MODULE_TYPES[idx]]();
            await delay(200);
            iter++;
          }
      }
    }

    runExperiment();
  }, [])

  const ButtonsHolder = () => {
    const jsiButtonClick = async () => {
      makeNetworkCallViaJSI.typeOfCommLayer = 'jsi';
      let iter = 0;
      while(iter < 600) {
        const callApi = getFunctionWithMeasures(makeNetworkCallViaJSI);

        const wrappedResponse = await callApi()
        appendResponse({ type: 'jsi', roundTrip: wrappedResponse.measure.timeTaken })

        await delay(200);
        iter++;
      }

    }

    const cprButtonClick = async () => {
      makeNetworkCallViaCPR.typeOfCommLayer = 'cpr';
      let iter = 0;
      while(iter < 600) {
        const callApi = getFunctionWithMeasures(makeNetworkCallViaCPR);

        const wrappedResponse = await callApi()
        appendResponse({ type: 'cpr', roundTrip: wrappedResponse.measure.timeTaken })
        await delay(200);
        iter++;
      }
    }

    const bridgeButtonClick = async () => {
      makeNetworkCallViaFetch.typeOfCommLayer = 'bridge';
      let iter = 0;
      while(iter < 600) {
        const callApi = getFunctionWithMeasures(makeNetworkCallViaFetch);

        const wrappedResponse = await callApi()
        appendResponse({ type: 'bridge', roundTrip: wrappedResponse.measure.timeTaken })
        await delay(200);
        iter++;
      }
    }

    const jsiCallbackButtonClick = async () => {
      global_start = Date.now();
      Skynet.makeRequest();
    }

    return (
      <View style={styles.buttonHolder}>
        <TouchableOpacity
          onPress={jsiButtonClick}
          style={[styles.button, { backgroundColor: COLORS.jsi }]}>
          <Text>jsi:Custom</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={cprButtonClick}
          style={[styles.button, { backgroundColor: COLORS.cpr }]}>
          <Text>jsi:cpr</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={bridgeButtonClick}
          style={[styles.button, { backgroundColor: COLORS.bridge }]}>
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
        <View style={{ marginVertical: 64}}>
          <Text
            style={{ ...styles.dataStrip, backgroundColor: COLORS[moduleUnderExperiment.current] }}>
            Module Under Experiment: {moduleUnderExperiment.current.toUpperCase()}
          </Text>
        </View>
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
