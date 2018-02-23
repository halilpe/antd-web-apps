<?lua
    local model = _G.dbmodel
    if #model.order == 0 then
?>
    <div class = "notfound">
       <p>No entry found</p>
       <blockquote>
        “In many ways my life has been rather like a record of the lost and found. Perhaps all lives are like that.”
<span>― Lucy Foley, The Book of Lost and Found</span> 
       </blockquote >
    </div>
<?lua
        return
    end

    for idx,v in pairs(model.order) do
        local data = model.data[v]
?>
<div class = "card">
    <div class = "side">
        <span class = "date"><?=data.ctimestr:gsub("%s+.*$","")?></span>
        <span class = "tags">
        <?lua
            local atags = {}
            local i = 1
            for tag in data.tags:gmatch(",*([^,]+)") do
                tag = std.trim(tag, " ")
                local b64tag = std.b64encode(tag)
                atags[i] = '<a href = "./bytag:'..b64tag:gsub("=","")..':'..MAX_ENTRY..'">'..tag.."</a>"
                i = i+ 1
            end
            echo(table.concat(atags, ", "))
        ?>
        </span>

    </div>
    <div class = "blogentry">
        <div class = "shortcontent">
            <?lua
                local content = bytes.__tostring(std.b64decode(data.rendered)):gsub("%%","%%%%")

                local r, s = content:find("(<hr/?>)")
                if r then 
                    content = content:sub(0,r-1)
                end
                echo(content)
            ?>
        </div>
        <div class = "detail">
                <span></span>
                <?='<a href="./id:'..data.id..'" ></a>'?>
                <span></span>
        </div>
    </div>
</div>
<?lua
    end
?>