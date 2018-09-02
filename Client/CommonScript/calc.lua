local tbCalc = {}
function tbCalc:Line(x, x1, y1, x2, y2)
  if x2 == x1 then
    return y2
  end
  return (y2 - y1) * (x - x1) / (x2 - x1) + y1
end
function tbCalc:LineY(y, x1, y1, x2, y2)
  if y2 == y1 then
    return x2
  end
  return (y - y1) * (x2 - x1) / (y2 - y1) + x1
end
function tbCalc:Conic(x, x1, y1, x2, y2)
  if x1 < 0 or x2 < 0 then
    return 0
  end
  if x2 == x1 then
    return y2
  end
  return (y2 - y1) * (x * x - x1 * x1) / (x2 * x2 - x1 * x1) + y1
end
function tbCalc:Extrac(x, x1, y1, x2, y2)
  if x1 < 0 or x2 < 0 then
    return 0
  end
  if x2 == x1 then
    return y2
  end
  return (y2 - y1) * (x ^ 0.5 - x1 ^ 0.5) / (x2 ^ 0.5 - x1 ^ 0.5) + y1
end
function tbCalc:Link(x, tbPoint, bFloat)
  if not tbPoint then
    return 0
  end
  if type(tbPoint) == "number" then
    return tbPoint
  end
  local nSize = #tbPoint
  assert(nSize >= 2)
  local nPoint2 = nSize
  local szFunc = tbPoint[nSize][3]
  for i = 1, nSize do
    if x < tbPoint[i][1] then
      if i == 1 then
        nPoint2 = 2
      else
        nPoint2 = i
      end
      szFunc = tbPoint[i][3]
      break
    end
  end
  local tb1 = tbPoint[nPoint2 - 1]
  local tb2 = tbPoint[nPoint2]
  szFunc = szFunc or "Line"
  local fnFunc = self[szFunc]
  assert(fnFunc)
  local nResult = fnFunc(self, x, tb1[1], tb1[2], tb2[1], tb2[2])
  if not bFloat then
    return math.floor(nResult)
  end
  return nResult
end
function tbCalc:LinkY(y, tbPoint, bFloat)
  if not tbPoint then
    return 0
  end
  if type(tbPoint) == "number" then
    return tbPoint
  end
  local nSize = #tbPoint
  assert(nSize >= 2)
  local nPoint2 = nSize
  local szFunc = tbPoint[nSize][3]
  for i = 1, nSize do
    if y < tbPoint[i][2] then
      if i == 1 then
        nPoint2 = 2
      else
        nPoint2 = i
      end
      szFunc = tbPoint[i][3]
      break
    end
  end
  local tb1 = tbPoint[nPoint2 - 1]
  local tb2 = tbPoint[nPoint2]
  szFunc = szFunc or "LineY"
  local fnFunc = self[szFunc]
  assert(fnFunc)
  local nResult = fnFunc(self, y, tb1[1], tb1[2], tb2[1], tb2[2])
  if not bFloat then
    return math.floor(nResult)
  end
  return nResult
end
Lib.Calc = tbCalc
