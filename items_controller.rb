class ItemsController < ApplicationController

  # GET /items
  # GET /items.json
  def index
    @items = Item.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

	def webpage

    @items = Item.where(:forsale => true)
		@paypals = Array.new
  	@buttons = Array.new
        @grind_options = ["Whole Bean", "French Press Grind", "Flat Drip Grind", "Cone Drip Grind"]
	@grind_fee = 1 # 1 dollar more for anything but whole bean

    @items.each do |item|

		  decrypted = { #PayPal Button data ready to be encrypted
	      "cert_id" => "REDACTED", #your cert id
	      "cmd" => "_cart",
	      "add" => "1",
	      "business" => "email@email.com", #your email
	      "item_name" => item.title+" "+item.subtitle,
	      "weight" => "0.8",
	      "weight_unit" => "lbs",
	      #"item_number" => "1",
	      #"custom" =>"something to pass to IPN",
	      "amount" => item.price.to_s,
	      "option_select0" => @grind_options[0],
	      "option_amount0" => (item.price).to_s, # no fee for whole bean
	      "option_select1" => @grind_options[1],
	      "option_amount1" => (item.price + @grind_fee).to_s, # grinding adds grind fee
	      "option_select2" => @grind_options[2],
	      "option_amount2" => (item.price + @grind_fee).to_s,
	      "option_select3" => @grind_options[3],
	      "option_amount3" => (item.price + @grind_fee).to_s,
	      "currency_code" => "USD",
	      "country" => "US",
	      "no_note" => "1",
	      "no_shipping" => "2",  #2 means customer must provide shipping address
		  }

      @buttons.append(Crypto42::Button.from_hash(decrypted).get_encrypted_text)
		end
    
		@paypals = @items.zip(@buttons)
                
		@page_data = render_to_string() # read the entire page's output to string
                File.open('public/coffeestore.html','w') {|f| f.write(@page_data) }
		
	end



	def upload
          require 'net/ftp'

       	  @items = Item.all

          ftp = Net::FTP.new('ftpserver')
          ftp.login("user", "pw")
	  ftp.chdir("www/wherever")
          ftp.putbinaryfile("public/coffeestore.html", "index.html") 
          ftp.close
	  
	  render :index
	end

		



  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        # format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.html { redirect_to items_url }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        #format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.html { redirect_to items_url }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
    end
  end
end
