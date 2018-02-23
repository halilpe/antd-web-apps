<?lua
    local data = _G.dbmodel
    if not #data then
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
                local r, s = content:find("<hr/?>")
                if r then
                    echo(content:sub(0,r-1))
                    echo(content:sub(s+1))
                else
                    echo(content)
                end
            ?>
        </div>
        <h1 class = "commentsec">Comments</h1>
        <div class = "commentform">
            <div  class = "inputbox">
                <div class = "label">Name:</div>
                <input data-class = "data" type = "text" name = "name" />
            </div>
            
            <div  class = "inputbox">
                <div  class = "label">Email:</div>
                <input data-class = "data" type = "text" name = "email" />
            </div>
            
            <textarea data-class = "data"  name = "content"></textarea>
            <div class = "inputboxbt">
                <div data-id="status"></div>
                <button data-id = "send" >Comment</button>
            </div>
        </div>
    </div>
</div>