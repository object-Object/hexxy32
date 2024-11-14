---@meta

---@class FocalLink
---@field receiveIota fun(): Iota
---@field clearReceivedIotas fun()
---@field remainingIotaCount fun(): number
---@field numLinked fun(): number
---@field unlink fun(index: number)
---@field sendIota fun(index: number, ...: Iota)

---@alias focalLinkType "focal_link"
