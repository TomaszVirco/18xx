# frozen_string_literal: true

require 'view/token'

module View
  class StockMarket < Snabberb::Component
    needs :game
    needs :show_bank, default: false

    COLOR_MAP = {
      red: '#ffaaaa',
      brown: '#8b4513',
      orange: '#ffbb55',
      yellow: '#ffff99',
    }.freeze

    PAD = 5                                     # between box contents and border
    BORDER = 1
    WIDTH_TOTAL = 50                            # of entire box, including border
    HEIGHT_TOTAL = 50
    TOKEN_PAD = 3                               # left/right padding of tokens within box
    TOKEN_SIZE = 25
    BOX_WIDTH = WIDTH_TOTAL - 2 * BORDER
    LEFT_MARGIN = TOKEN_PAD                     # left edge of leftmost token
    RIGHT_MARGIN = BOX_WIDTH - TOKEN_PAD        # right edge of rightmost token
    LEFT_TOKEN_POS = LEFT_MARGIN
    RIGHT_TOKEN_POS = RIGHT_MARGIN - TOKEN_SIZE # left edge of rightmost token
    MID_TOKEN_POS = (LEFT_TOKEN_POS + RIGHT_TOKEN_POS) / 2

    def render
      space_style = {
        position: 'relative',
        display: 'inline-block',
        padding: "#{PAD}px",
        width: "#{WIDTH_TOTAL - 2 * PAD}px",
        height: "#{HEIGHT_TOTAL - 2 * PAD}px",
        margin: '0',
        'vertical-align': 'top',
      }

      box_style = space_style.merge(
        width: "#{WIDTH_TOTAL - 2 * PAD - 2 * BORDER}px",
        height: "#{HEIGHT_TOTAL - 2 * PAD - 2 * BORDER}px",
        border: "solid #{BORDER}px rgba(0,0,0,0.2)",
      )

      grid = @game.stock_market.market.flat_map do |prices|
        rows = prices.map do |price|
          if price
            style = box_style.merge('background-color' => COLOR_MAP[price.color])

            corporations = price.corporations
            num = corporations.size
            spacing = num > 1 ? (RIGHT_TOKEN_POS - LEFT_TOKEN_POS) / (num - 1) : 0

            tokens = corporations.map.with_index do |corporation, index|
              props = {
                attrs: { data: corporation.logo, width: "#{TOKEN_SIZE}px" },
                style: {
                  position: 'absolute',
                  left: num > 1 ? "#{LEFT_TOKEN_POS + ((num - index - 1) * spacing)}px" : "#{MID_TOKEN_POS}px",
                  'z-index' => num - index,
                },
              }
              h(:object, props)
            end

            h(:div, { style: style }, [
              h(:div, { style: { 'font-size': '80%' } }, price.price),
              h(:div, tokens),
            ])
          else
            h(:div, { style: space_style }, '')
          end
        end

        h(:div, { style: { width: 'max-content' } }, rows)
      end

      bank_props = {
        style: {
          'margin-bottom': '1rem',
        },
      }

      children = []

      children << h(:div, bank_props, "Bank Cash: #{@game.format_currency(@game.bank.cash)}") if @show_bank
      children.concat(grid)

      props = {
        style: {
          width: '100%',
          overflow: 'auto',
        },
      }

      h(:div, props, children)
    end
  end
end
