formspec_helper = {
    subscriptions = {}
}

function formspec_helper:subscribe(formspec_name, player_name)
    if self.subscriptions[formspec_name] == nil then
        self.subscriptions[formspec_name] = {}
    end
    table.insert(self.subscriptions[formspec_name], {name = player_name, pos = nil})
end

function formspec_helper:multicast(formspec_name, formspec)
    if self.subscriptions ~= nil and self.subscriptions[formspec_name] ~= nil then
        local subscribers = self.subscriptions[formspec_name]
        for _, subscriber in ipairs(subscribers) do
            core.show_formspec(subscriber.name, formspec_name, formspec)
        end
    end
end

function formspec_helper:unsubscribe(formspec_name, player)
    if self.subscriptions[formspec_name] == nil then
        self.subscriptions[formspec_name] = {}
        return
    end
    for i, subscriber in ipairs(self.subscriptions[formspec_name]) do
        if player == subscriber then
            table.remove(self.subscriptions[formspec_name], i)
            break
        end
    end
end

