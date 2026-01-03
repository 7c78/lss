export const sleep = (ms) => () => {
    let sab = new SharedArrayBuffer(4)
    let int32 = new Int32Array(sab)
    Atomics.wait(int32, 0, 0, ms)
}
