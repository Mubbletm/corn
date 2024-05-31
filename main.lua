-- Instantiate variables
local query = get("query");
local btn = get("search-button")
local rndmbtn = get("random-button")

local items = get("item", true);
local itemName = get("item-name", true);
local itemUrl = get("item-url", true);
local itemIp = get("item-ip", true);

-- IP ban list, these IPs don't go anywhere
local banlist = {
    "1.1.1.1",
    "localhost",
    "google.com",
    "127.0.0.1",
    "a",
    "69.69.69",
    "0.0.0.0",
    "reserved",
    "buss://"
}

local potentialPrefixes = {
    "",
    "https://",
    "http://"
}

-- Fetch data
local _response = fetch({
    url = "https://api.buss.lol/domains",
    method = "GET",
    headers = { },
    body = ""
});


-- Process ban list
local response = {};
local banned = {}

-- Create all possible combinations of banned addresses and prefixes.
for index, prefix in pairs(potentialPrefixes) do
    for j, ban in pairs(banlist) do
        table.insert(banned, (prefix .. ban));
    end
end

-- Filter the list for 'IPs' that start with banned phrases. We want to weed out the majority
-- of invalid 'IPs'.
for index, item in pairs(_response) do
    local ip = item["ip"];
    local isBanned = false;
    for j, ban in pairs(banned) do
        if string.sub(ip, 1, #ban) == ban then
            isBanned = true;
            break;
        end
    end
    if isBanned == false then
        table.insert(response, item);
    end
end

-- Main thread
function main()
    clearItems();
end

-- Declare functions
------------------------------------
-- Get URL of an item
function getURL(item)
    return (item["name"] .. "." .. item["tld"]);
end

-- Clears all items from the results.
function clearItems()
    for index, item in pairs(items) do
        item.set_opacity(0);
    end
end

-- Displays the given item at the given index in the results.
function displayItem(index, item)
    local itemEl = items[index];
    local nameEl = itemName[index];
    local ipEl = itemIp[index];
    local urlEl = itemUrl[index];

    local url = "buss://" .. getURL(item);

    itemEl.set_opacity(1);
    nameEl.set_content(item["name"]);
    ipEl.set_content(item["ip"]);
    urlEl.set_content(url);
    urlEl.set_href(url);
end

-- Displays an array of items in the results.
function displayItems(arr)
    clearItems();
    for index, item in pairs(arr) do
        displayItem(index, item)
    end
end

-- Filters all the items for items that match the given query string.
function filterItems(queryString)
    local filtered = {};
    for index, item in pairs(response) do
        local url = getURL(item);
        -- We want pages that have the query in their domain name to be at the top of the results.
        -- If we find the query inside the 'IP' we want them to be at the bottom, since they might not
        -- be as relevant.
        if string.find(string.lower(url), string.lower(queryString)) then
            table.insert(filtered, 1, item);
        elseif string.find(string.lower(item["ip"]), string.lower(queryString)) then
            table.insert(filtered, item);
        end
    end
    return filtered;
end

-- Returns a random item from the list of items.
function getRandomItem()
    return response[math.random(#response)];
end

-- Retrieve the contents of the input and apply the query.
function applyQuery(queryString)
    displayItems(filterItems(query.get_content()));
end

-- Event Listeners
query.on_submit(applyQuery);
btn.on_click(applyQuery);
rndmbtn.on_click(function()
    clearItems();
    displayItem(1, getRandomItem());
end)

-- Run main thread
main();
