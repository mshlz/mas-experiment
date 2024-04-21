import http from "node:http"
import express from "express"
import cors from "cors"
import ms from "ms"
import * as pkg from "../package.json"

const app = express()
const server = http.createServer(app)

app.use(cors())

app.get("/health", (req, res) => {
  res.json({ status: "ok", commit: pkg.commit })
})

app.all<any, any>("/wait", (req, res) => {
  const start = Date.now()
  const timeout = ms("3 secs")

  setTimeout(() => {
    res.json({
      elapsed: Date.now() - start,
      timeout: ms(timeout),
    })
  }, timeout)
})

// ------------------------------------------------------------------------------------------------
const onFinishResponseCbs: (() => any)[] = []

app.all<any, any>("/wait-close", (req, res) => {
  onFinishResponseCbs.push(() => res.end("done"))
})
// ------------------------------------------------------------------------------------------------

console.log("PID =>", process.pid)

const keepAliveTimer = setInterval(() => {
  // server.getConnections((err, count) => {
  //   console.log("Connections: %d", count, err ?? "")
  // })
}, 1000)

const startServer = () => {
  const PORT = process.env.PORT || 3001
  server.listen(PORT, () => console.log(`Server started at http://localhost:${PORT}`))
}

const closeServer = (cb?: (err?: any) => void) => {
  if (server.listening) {
    server.close(cb)

    let finishCb = null
    while ((finishCb = onFinishResponseCbs.pop())) {
      finishCb()
    }
  }
}

server.on("close", () => {
  console.log("Server is CLOSED")
  // process.exit(0)
})

process.on("SIGINT", () => {
  console.log("Server received SIGINT...")
  closeServer()
})

process.on("SIGHUP", () => {
  console.log("Server received SIGHUP...")
  if (server.listening) {
    console.log("[already listening]")
  } else {
    console.log("[restarting...]")
    startServer()
  }
})

process.on("SIGTERM", () => {
  console.log("Server received SIGTERM...")
  server.getConnections((err, count) => {
    console.log("Connections: %s | Callbacks: %d", count, onFinishResponseCbs.length)
  })
  clearInterval(keepAliveTimer)
  closeServer(err => { 
    console.log("[SERVER EXITING]")
    if (err && err.code !== "ERR_SERVER_NOT_RUNNING") {
      console.error(err)
      process.exit(1)
    } else {
      process.exit(0)
    }
  })
})

startServer()

