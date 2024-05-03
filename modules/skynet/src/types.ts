type NetworkModule = {
  /**
   * client is expected to call this, with configurations like base url and stuff
   * @returns {boolean}
   */
  init: () => boolean;
  /**
   * currently this is a syncronous method, but eventually this will be an async method
   * @returns {string}
   */
  makeRequest: () => Promise<string>;
};

/**
 * this is what the final thing would look like
 */
// makeRequest: async <ResponseType = {}>(): Promise<ResponseType> => {
//   return new Promise((resolve, _reject) => {
//     callbackBasedApi(requestBody, response => {
//       if (response.ok === false) {
//         _reject(); // with some wrapping logic
//         return;
//       }
//       resolve(response); // with some additional wrapping logic
//     });
//     const callback = response => {
//       if (response.ok) {
//         Promise.resolve();
//         return;
//       }

//       Promise.reject();
//     };
//   });
// };

export type {NetworkModule};
