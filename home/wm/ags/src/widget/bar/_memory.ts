import { exec, Variable } from 'astal'

const memTotalLine = exec(['cat', '/proc/meminfo'])
  .split('\n')[0]
  .match(/MemTotal:\s*(\d+)\s* kB/)

if (memTotalLine === null) {
    throw console.error("memTotal cannot get");
} 

const memTotal = Number.parseInt(
   memTotalLine[1].toString(),
)
export const memInfo = Variable({
  usage: 0,
  total: 0,
}).poll(2000, ['cat', '/proc/meminfo'], (content, prev) => {
    console.log(content)
})
