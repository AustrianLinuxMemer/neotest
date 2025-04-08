formspec_helper = {}
formspec_names = {}
function formspec_helper.subscribe(subscriber_list, subscriber)
    table.insert(subscriber_list, subscriber)
end
function formspec_helper.multicast(subscriber_list, formspec_name, formspec)
    if subscriber_list == nil then return end
    for _, subscriber in ipairs(subscriber_list) do
        core.show_formspec(subscriber, formspec_name, formspec)
    end
end
function formspec_helper.unsubscribe(subscriber_list, subscriber)
    if subscriber_list == nil then return end
    for i, s in ipairs(subscriber_list) do
        if s == subscriber then table.remove(subscriber_list, i) end
    end
end