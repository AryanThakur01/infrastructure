function CodeBlock(el)
  if el.classes[1] == "mermaid" then
    local file = os.tmpname() .. ".mmd"
    local out = os.tmpname() .. ".png"

    local f = io.open(file, "w")
    f:write(el.text)
    f:close()

    os.execute("mmdc -i " .. file .. " -o " .. out)

    return pandoc.Para{
      pandoc.Image({}, out)
    }
  end
end
