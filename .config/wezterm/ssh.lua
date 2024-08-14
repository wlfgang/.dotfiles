local module = {}
function module.apply_to_config(config)
    -- add your ssh domains here
    config.ssh_domains = {
        {
            name = "-",
            remote_address = "-",
            username = "-",
        },
    }
end

-- return our module table
return module
