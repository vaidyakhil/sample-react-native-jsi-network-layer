declare global {
  function skynet_rn_jsi_makeRequest(arg: any): Promise<string>;
  function skynet_rn_jsi_sendRequest(
    requestBody: {skynet_rn_jsi_uniqueId: string},
    nativeCallback: (responseData: any, errorData: any | undefined) => void,
  ): Promise<any>;
}

export {};
