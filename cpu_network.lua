function Split(s, delimiter)
    result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

function check_network_connected(routes_text, interface)
    if string.find(routes_text, interface) then
        return true
    end
    return false
end

function conky_mynetwork()
    local file = io.popen("ls -1 /sys/class/net")
    local interfaces = file:read("*a")
    file:close()

    local file = io.popen("cat /proc/net/route")
    local routes_text = file:read("*a")
    file:close()

    interfaces_a = Split(interfaces, "\n")

    for num, inter in pairs(interfaces_a) do
        if (inter == "" or inter == "lo") then
            table.remove(interfaces_a, num)
        end
    end
    offset_int = 56
    result = ""
    if (#interfaces_a > 0) then
        if (#interfaces_a > 1) then
            for i = 1, #interfaces_a do
                if (check_network_connected(routes_text, interfaces_a[i])) then
                    if (i ~= #interfaces_a) then
                        result = result .. "${alignr}${offset -" .. offset_int ..
                                     "}                                                           │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${addr " .. interfaces_a[i] ..
                                     "} ] " .. interfaces_a[i] .. " ─┤\n"
                        result =
                            result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeed " .. interfaces_a[i] ..
                                "} k/s ] download ─┤    │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeedgraph " ..
                                     interfaces_a[i] .. " 12,120 136311 11B014} ] ─┘    │    │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeed " .. interfaces_a[i] ..
                                     "} k/s ]   upload ─┘    │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeedgraph " ..
                                     interfaces_a[i] .. " 12,120 BA0B0B FC0707} ] ─┘         │\n"

                    else
                        result = result .. "${alignr}${offset -" .. offset_int ..
                                     "}                                                           │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${addr " .. interfaces_a[i] ..
                                     "} ] " .. interfaces_a[i] .. " ─┘\n"
                        result =
                            result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeed " .. interfaces_a[i] ..
                                "} k/s ] download ─┤     \n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeedgraph " ..
                                     interfaces_a[i] .. " 12,120 136311 11B014} ] ─┘    │     \n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeed " .. interfaces_a[i] ..
                                     "} k/s ]   upload ─┘     \n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeedgraph " ..
                                     interfaces_a[i] .. " 12,120 BA0B0B FC0707} ] ─┘          \n"
                    end
                end
            end
        else
            if (check_network_connected(routes_text, interfaces_a[1])) then
                result = result .. "${alignr}${offset -" .. offset_int ..
                             "}                                                           │\n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${addr " .. interfaces_a[1] .. "} ] " ..
                             interfaces_a[1] .. " ─┘\n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeed " .. interfaces_a[1] ..
                             "} k/s ] download ─┤     \n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeedgraph " .. interfaces_a[1] ..
                             " 12,120 136311 11B014} ] ─┘    │     \n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeed " .. interfaces_a[1] ..
                             "} k/s ]   upload ─┘     \n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeedgraph " .. interfaces_a[1] ..
                             " 12,120 BA0B0B FC0707} ] ─┘          \n"
            else
                result = "${alignr}${offset -" .. offset_int .. "} No Network Available ─┘"
            end
        end
    else
        result = "${alignr}${offset -" .. offset_int .. "} No Network Available ─┘"
    end
    return result
end

function conky_mycpus()
    local file = io.popen("grep -c processor /proc/cpuinfo")
    local numcpus = file:read("*n")
    file:close()
    listcpus = ""
    for i = 1, numcpus do
        if (i == numcpus) then
            listcpus = listcpus .. "${alignr}${offset -6}[ ${cpu cpu" .. tostring(i) .. "}% ] cpu" .. tostring(i) ..
                           " ─┘   │   │    "
        else
            listcpus = listcpus .. "${alignr}${offset -6}[ ${cpu cpu" .. tostring(i) .. "}% ] cpu" .. tostring(i) ..
                           " ─┤   │   │    \n"
        end
    end
    return listcpus
end
