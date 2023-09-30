local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
  content = {
    width = 800,
    height = aspectRatio < 1.5 and 1200 or math.ceil( 800 * aspectRatio ),
    scale = "letterBox",
    fps = 30,
    imageSuffix = {
      ["@2x"] = 1.3
    },
  },
}