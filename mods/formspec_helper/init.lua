formspec_helper = {
    subscriptions = {}
}

function formspec_helper:subscribe(formspec_name, player_name)
    if self.subscriptions[formspec_name] == nil then
        self.subscriptions[formspec_name] = {}
    end
    table.insert(self.subscriptions[formspec_name], player_name)
end

function formspec_helper:multicast(formspec_name, formspec)
    if self.subscriptions ~= nil and self.subscriptions[formspec_name] ~= nil then
        local subscribers = self.subscriptions[formspec_name]
        for _, subscriber in ipairs(subscribers) do
            core.show_formspec(subscriber, formspec_name, formspec)
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

function formspec_helper:unsubscribe_from_all(player)
    if self.subscriptions[formspec_name] == nil then
        self.subscriptions[formspec_name] = {}
        return
    end
    for formspec_name, _ in pairs(self.subscriptions) do
        local formspec_subscribers = self.subscriptions[formspec_name]
        for i, subscriber in ipairs(formspec_subscribers) do
            if player == subscriber then
                table.remove(formspec_subscribers, i)
            end
        end
        self.subscriptions[formspec_name] = formspec_subscribers
    end
end

-- Unsubscribe from all formspec events when player leaves
core.register_on_leaveplayer(function(player, timed_out)
    if player:is_player() then
        formspec_helper:unsubscribe_from_all(player:get_player_name())
    end
end)

