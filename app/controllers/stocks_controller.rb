class StocksController < ApplicationController
 
def intraday
  @stocks = current_user.stocks
  @stock_symbol = params[:symbol]&.upcase
  
  if @stock_symbol.present?
    begin
      api = AlphaVantageApi.new
      @intraday_data = api.time_series_intraday(@stock_symbol)
      
      if @intraday_data.present? && @intraday_data['Meta Data'] && @intraday_data['Time Series (5min)'].present?
        @stock_symbol = @intraday_data['Meta Data']['2. Symbol']
        @latest_open_value = @intraday_data['Time Series (5min)'].values.first&.dig('1. open')&.to_f
        
        if @latest_open_value
          @current_holdings = Stock.where(user_id: current_user.id, symbol: @stock_symbol)
                                 .sum(:quantity)
        else
          flash.now[:alert] = "Unable to fetch current price for #{@stock_symbol}"
        end
      else
        flash.now[:alert] = "Unable to fetch intraday data for #{@stock_symbol}"
      end
    rescue => e
      flash.now[:alert] = "Error fetching stock data: #{e.message}"
      @intraday_data = nil
    end
  end
end

  def buy
    stock_symbol = params[:symbol]
    quantity = params[:quantity].to_i

    if stock_symbol.present? && quantity > 0
      api = AlphaVantageApi.new
      intraday_data = api.time_series_intraday(stock_symbol)
      
      if intraday_data.present? && intraday_data['Time Series (5min)']
        latest_open_value = intraday_data['Time Series (5min)'].values.first.dig('1. open').to_f
        total_price = quantity * latest_open_value
        
        if (current_user.balance > 0) && (current_user.balance >=total_price)

          stock = current_user.stocks.find_or_initialize_by(symbol: stock_symbol, stock_name: stock_symbol)
          stock.quantity = stock.quantity.to_i + quantity
          stock.price_per_stock = latest_open_value.to_f
          stock.stock_value = latest_open_value.to_f
          stock.total_price = ((stock.total_price || 0) + total_price).to_f
          stock.save!

          current_user.transactions.create(
            transaction_type: "buy",
            symbol: stock_symbol.upcase,
            stock_name: stock_symbol.upcase,
            quantity: quantity,
            stock_value: latest_open_value.to_f,
            price_per_stock: latest_open_value.to_f,
            total_price: total_price.to_f
          )

          current_user.update!(balance: current_user.balance - total_price)

          flash[:notice] = "Transaction successful!"

        else
            flash[:alert] = "Insufficient funds"
        end
      else
        flash[:alert] = "Unable to fetch stock data. Please try again."
      end
    else
      flash[:alert] = "Quantity must be greater than 0."
    end

    redirect_to intraday_stocks_path(symbol: stock_symbol)
  end


  def sell
    stock_symbol = params[:symbol]
    quantity = params[:quantity].to_i

    if stock_symbol.present? && quantity > 0
      api = AlphaVantageApi.new
      intraday_data = api.time_series_intraday(stock_symbol)
      
      if intraday_data.present? && intraday_data['Time Series (5min)']
        latest_open_value = intraday_data['Time Series (5min)'].values.first.dig('1. open').to_f
        

        stock = current_user.stocks.find_or_initialize_by(symbol: stock_symbol, stock_name: stock_symbol)
        stock.quantity = stock.quantity.to_i - quantity
        stock.price_per_stock = stock.price_per_stock.to_f
        stock.stock_value = latest_open_value.to_f
        total_price = (quantity * stock.stock_value).to_f
        stock.total_price = ((stock.total_price || 0) + total_price).to_f
        stock.save!

        current_user.transactions.create(
            transaction_type: "sell",
            symbol: stock_symbol.upcase,
            stock_name: stock_symbol.upcase,
            quantity: quantity,
            stock_value: latest_open_value.to_f,
            price_per_stock: stock.price_per_stock,
            total_price: total_price.to_f
          )


        current_user.update!(balance: current_user.balance + total_price)

        flash[:notice] = "Transaction successful!"
      else
        flash[:alert] = "Unable to fetch stock data. Please try again."
      end
    else
      flash[:alert] = "Invalid purchase details. Quantity must be greater than 0."
    end

    redirect_to intraday_stocks_path(symbol: stock_symbol)
  end

  def portfolio
  @stocks = current_user.stocks.where("quantity > 0")
  # Get latest prices for all stocks
  api = AlphaVantageApi.new
  @stock_data = {}
  
  @stocks.each do |stock|
    intraday_data = api.time_series_intraday(stock.symbol)
    if intraday_data.present? && intraday_data['Time Series (5min)']
      latest_price = intraday_data['Time Series (5min)'].values.first.dig('1. open').to_f
      @stock_data[stock.symbol] = {
        current_price: latest_price,
        total_value: latest_price * stock.quantity,
        gain_loss: ((latest_price - stock.price_per_stock) * stock.quantity).round(2),
        gain_loss_percentage: (((latest_price - stock.price_per_stock) / stock.price_per_stock) * 100).round(2)
      }
    end
  end
end

end