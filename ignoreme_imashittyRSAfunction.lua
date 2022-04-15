local function isPrime(n)
    if n <= 3 then return n > 1 end
    if not (n%2) or not (n%3) then return false end
    local i = 5
    while math.pow(i, 2) <= n do
        if not (n%i) or not (n%(i + 2)) then return false end
        i = i + 6
    end
    return true
end

local function gcd( m, n )
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

local function lcm( m, n )
    return ( m ~= 0 and n ~= 0 ) and m * n / gcd( m, n ) or 0
end


local p
local q

local i = false
while i == false do
    print("making p")
    math.randomseed(os.epoch("utc"))
    p = math.random(100, 1000)
    if isPrime(p) then i = true end
end

i = false
while i == false do
    print("making q")
    math.randomseed(os.epoch("utc"))
    q = math.random(100000, 1000000)
    if isPrime(q) then i = true end
end

local n = (p*q)
print("making toient n")
local toient_n = lcm(p-1, q-1)
print(toient_n)

local e

i = false
while i == false do
    math.randomseed(os.epoch("utc"))
    e = math.random(1, toient_n)
    print(e)
    if gcd(e, toient_n) == 1 then i = true end
end

local d = toient_n/e

local keys = { public={n=n,e=e}, private={n=n,d=d} }
local file = fs.open("keys.cfg", "w")
file.write(textutils.serialize(keys, { compact = true, allow_repetitions = false }))
file.close()