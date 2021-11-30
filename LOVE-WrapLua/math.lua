function love.math.setRandomSeed(seed)
    return math.randomseed(seed)
end

function love.math.random(a,b)
    return math.random(a,b)
end

function love.math.triangulate(polygon)
    -- Reference here: https://2dengine.com/?p=polygons#Triangulation
    local function signedPolygonArea(p)
        local s = 0
        local n = #p
        local a = p[n]
        for i = 1, n do
            local b = p[i]
            s = s + (b.x + a.x)*(b.y - a.y)
            a = b
        end
        return s
    end
    
    local function isPolygonCounterClockwise(p)
        return signedPolygonArea(p) > 0
    end
    
    local function polygonReverse(p)
        local n = #p
        for i = 1, math.floor(n/2) do
            local i2 = n - i + 1
            p[i], p[i2] = p[i2], p[i]
        end
    end

    local function pointInTriangle(p, p1, p2, p3)
        local ox, oy = p.x, p.y
        local px1, py1 = p1.x - ox, p1.y - oy
        local px2, py2 = p2.x - ox, p2.y - oy
        local ab = px1*py2 - py1*px2
        local px3, py3 = p3.x - ox, p3.y - oy
        local bc = px2*py3 - py2*px3
        local sab = ab < 0
        if sab ~= (bc < 0) then
            return false
        end
        local ca = px3*py1 - py3*px1
        return sab == (ca < 0)
    end

    local function signedTriangleArea(p1, p2, p3)
        return (p1.x - p3.x)*(p2.y - p3.y) - (p1.y - p3.y)*(p2.x - p3.x)
    end
    
    if not isPolygonCounterClockwise(polygon) then
        polygonReverse(polygon)
    end

    local left, right = {}, {}

    for i = 1, #polygon do
        local v = polygon[i]
        left[v], right[v] = polygon[i - 1], polygon[i + 1]
    end
    
    local first, last = polygon[1], polygon[#polygon]
    left[first], right[last] = last, first
    
    local triangles = {}
    local nskip = 0
    local i1 = first
    while #polygon >= 3 and nskip <= #polygon do
        local i0, i2 = left[i1], right[i1]
        local function isEar(i0, i1, i2)
            if signedTriangleArea(i0, i1, i2) >= 0 then
                local j1 = right[i2]
                repeat
                    local j0, j2 = left[j1], right[j1]
                    if signedTriangleArea(j0, j1, j2) <= 0 then
                        if pointInTriangle(j1, i0, i1, i2) then
                            return false
                        end
                    end
                    j1 = j2
                until j1 == i0
                return true
            end
            return false
        end
        
        if #polygon > 3 and isEar(i0, i1, i2) then
            table.insert(triangles, { i0, i1, i2 })
            left[i2], right[i0] = i0, i2     
            left[i1], right[i1] = nil, nil
            nskip = 0
            i1 = i0
        else
            nskip = nskip + 1
            i1 = i2
        end
    end

    return triangles
end