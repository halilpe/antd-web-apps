<?lua
    if HEADER.mobile then return end
    local args = {...}
    local data = args[1].data
    if not data then return end
?>
<div class = "cv-toc">
<ul>
<?lua
    for k, v in pairs(data) do
?>
    <li><a href=<?='"#toc'..v[2]..'"'?>><?=v[1]?></a></li>
<?lua
    end
?>
</ul>
</div>