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

    interfaces_a = {}

    for num, inter in pairs(Split(interfaces, "\n")) do
        if (inter ~= "" and inter ~= "lo" and not string.find(inter, "vmnet")) then
            table.insert(interfaces_a, inter)
        end
    end
    offset_int = 53
    result = ""
    if (#interfaces_a > 0) then
        if (#interfaces_a > 1) then
            for i = 1, #interfaces_a do
                if (check_network_connected(routes_text, interfaces_a[i])) then
                    if (i ~= #interfaces_a) then
                        result = result .. "${alignr}${offset -" .. offset_int .. "}│\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${addr " .. interfaces_a[i] ..
                                     "} ] " .. interfaces_a[i] .. " ─┤\n"
                        result =
                            result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeed " .. interfaces_a[i] ..
                                "} k/s ] download ─┤   │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeedgraph " ..
                                     interfaces_a[i] .. " 12,96 136311 11B014} ] ─┘    │   │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeed " .. interfaces_a[i] ..
                                     "} k/s ]   upload ─┘   │\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeedgraph " ..
                                     interfaces_a[i] .. " 12,96 BA0B0B FC0707} ] ─┘        │\n"

                    else
                        result = result .. "${alignr}${offset -" .. offset_int .. "}│\n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${addr " .. interfaces_a[i] ..
                                     "} ] " .. interfaces_a[i] .. " ─┘\n"
                        result =
                            result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeed " .. interfaces_a[i] ..
                                "} k/s ] download ─┤    \n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeedgraph " ..
                                     interfaces_a[i] .. " 12,102 136311 11B014} ] ─┘   │    \n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeed " .. interfaces_a[i] ..
                                     "} k/s ]   upload ─┘    \n"
                        result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeedgraph " ..
                                     interfaces_a[i] .. " 12,102 BA0B0B FC0707} ] ─┘        \n"
                    end
                end
            end
        else
            if (check_network_connected(routes_text, interfaces_a[1])) then

                result = result .. "${alignr}${offset -" .. offset_int .. "}│\n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${addr " .. interfaces_a[1] .. "} ] " ..
                             interfaces_a[1] .. " ─┘\n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeed " .. interfaces_a[1] ..
                             "} k/s ] download ─┤    \n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${downspeedgraph " .. interfaces_a[1] ..
                             " 12,96 136311 11B014} ] ─┘    │    \n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeed " .. interfaces_a[1] ..
                             "} k/s ]   upload ─┘    \n"
                result = result .. "${alignr}${offset -" .. offset_int .. "}[ ${upspeedgraph " .. interfaces_a[1] ..
                             " 12,96 BA0B0B FC0707} ] ─┘         \n"
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
	    spaces = string.rep(" ", 3 - math.ceil(i/9))
	    string1 = spaces .. "cpu"
            listcpus = listcpus .. "${alignr}${offset -6}[ ${cpu cpu" .. tostring(i) .. "}% ]".. string1 .. tostring(i) ..
                           " ─┘   │   │    "
        else
            spaces = string.rep(" ", 3 - math.ceil(i/9))
            string1 = spaces .. "cpu"
            listcpus = listcpus .. "${alignr}${offset -6}[ ${cpu cpu" .. tostring(i) .. "}% ]".. string1 .. tostring(i) ..
                           " ─┤   │   │    \n"
        end
    end
    return listcpus
end

function conky_mymounts()
    local file = io.popen("df --output='source,target' 2>/dev/null")
    local mount_list_from_df = file:read("*all")
    file:close()

    mount_list_array = Split(mount_list_from_df, "\n")

    mount_points = {}

    for num, inter in pairs(mount_list_array) do
        if (inter ~= "" and inter ~= "Operation not permitted" and not string.find(inter, "tmpfs") and
            not string.find(inter, "boot") and not string.find(inter, "snap")) then
            if (string.find(mount_list_array[num], "/dev/") or string.find(mount_list_array[num], ":/")) then
                str = string.gsub(mount_list_array[num], "%s+", " ")
                mount_point_with_dev = Split(str, " ")
                table.insert(mount_points, mount_point_with_dev[2])
            end
        end
    end

    result = ""

    for i = 1, #mount_points do
        if (i ~= #mount_points) then
            result = result .. "${alignr}${offset -30}" .. mount_points[i] .. " [ ${fs_used " .. mount_points[i] .. "}/${fs_size " ..
                         mount_points[i] .. "} ] ─┤   │\n"
            result = result .. "${alignr}${offset -30}[ ${fs_bar 5,120 " .. mount_points[i] ..
                         "} ] ─┘   │   │\n"
        else
            result = result .. "${alignr}${offset -30}" .. mount_points[i] .. " [ ${fs_used " .. mount_points[i] .. "}/${fs_size " ..
                         mount_points[i] .. "} ] ─┘   │\n"
            result = result .. "${alignr}${offset -12}[ ${fs_bar 5,120 " .. mount_points[i] .. "} ] ─┘       │"
        end

    end
    return result
end
