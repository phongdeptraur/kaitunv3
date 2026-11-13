-- Verify 2 supports + 1 clone present and moon is full (m == 2)
                    if (#presentSups == 2) and (#presentClones >= 1) and ST.m == 2 and table.find(presentClones, PlayerName) then
                        ST.ph = "gear"
                        RunHub("gear", function() RunKaitunV4(presentSups, presentClones) end)
                        return
                    end

                    if getgenv().V4Hub == "gear" and ST.m ~= 2 then
                        getgenv().V4Hub = nil
                        if type(getgenv().config) == "table" then
                            getgenv().config.Enabled = false
                        end
                        if getgenv().AutoV4Cleanup then
                            pcall(getgenv().AutoV4Cleanup)
                        end
                        return HopLowServer(false)
                    end
