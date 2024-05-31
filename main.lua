local query = get("query");
local btn = get("search-button")
local rndmbtn = get("random-button")

local items = get("item", true);
local itemName = get("item-name", true);
local itemUrl = get("item-url", true);
local itemIp = get("item-ip", true);

for index, item in pairs(items) do
    item.set_opacity(0);
end

local response = fetch({
    url = "https://api.buss.lol/domains",
    method = "GET",
    headers = { },
    body = ""
});

function queryServer(content)
    for index, item in pairs(items) do
        item.set_opacity(0);
    end

    local filtered = {};
    for index, item in pairs(response) do
        local url = (item["name"] .. "." .. item["tld"]);
        if string.find(string.lower(url), string.lower(content)) then
            table.insert(filtered, item);
        end
    end

    for index, item in pairs(filtered) do
        local itemEl = items[index];
        local nameEl = itemName[index];
        local ipEl = itemIp[index];
        local urlEl = itemUrl[index];

        local url = "buss://" .. item["name"] .. "." .. item["tld"];

        itemEl.set_opacity(1);
        nameEl.set_content(item["name"]);
        ipEl.set_content(item["ip"]);
        urlEl.set_content(url);
        urlEl.set_href(url);
    end
end

query.on_submit(queryServer);

btn.on_click(function()
    queryServer(query.get_content())
end)

rndmbtn.on_click(function()
    for index, item in pairs(items) do
        item.set_opacity(0);
    end

    local field = items[1];
    local itemEl = items[1];
    local nameEl = itemName[1];
    local ipEl = itemIp[1];
    local urlEl = itemUrl[1];

    field.set_opacity(1);

    local item = response[math.random(#response)];
    local url = "buss://" .. item["name"] .. "." .. item["tld"];

    itemEl.set_opacity(1);
    nameEl.set_content(item["name"]);
    ipEl.set_content(item["ip"]);
    urlEl.set_content(url);
    urlEl.set_href(url);
end)
