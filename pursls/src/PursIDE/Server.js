import net from "net"

export const _send = (port) => (command) => (resolve) => (reject) => () => {
    let client = net.createConnection({ port }, () => {
        client.write(command + "\n")
    })

    let result = ""
    client.on("data", (data) => {
        result += data
    })
    client.on("end", () => {
        resolve(result)()
    })
    client.on("error", (err) => {
        reject(err)()
    })
}
