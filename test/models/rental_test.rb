require "test_helper"

describe Rental do
  before do
    @rental = Rental.new(
      customer_id: customers(:customer1).id, 
      video_id: videos(:video1).id, 
      videos_checked_out_count: customers(:customer1).videos_checked_out_count, 
      available_inventory: videos(:video1).available_inventory 
    )
    @invalid_rental = Rental.new(
      customer_id: customers(:customer1).id, 
      video_id: nil,
      videos_checked_out_count: customers(:customer1).videos_checked_out_count, 
      available_inventory: nil
    )
  end

  describe 'validations' do

    it 'is valid when video_id and customer_id are present' do
      result = @rental.valid?
      expect(result).must_equal true
    end

    it 'is invalid when required params are not present' do
      result = @invalid_rental.valid?
      @rental.customer_id = nil
      expect(result).must_equal false
      expect(@rental.valid?).must_equal false
    end

    it 'validates if available_inventory and videos_checked_out_count are integers' do
      expect(@rental.valid?).must_equal true
      expect(@invalid_rental.valid?).must_equal false
     

      @rental.available_inventory = 1.2
      @rental.save
      expect(@rental.valid?).must_equal false

      @rental.available_inventory = videos(:video1).available_inventory 
      @rental.videos_checked_out_count = 3.5
      @rental.save
      expect(@rental.valid?).must_equal false

      
    end

    it 'validates if available_inventory and videos_checked_out_count are >= 0' do
      expect(@rental.valid?).must_equal true
      expect(@invalid_rental.valid?).must_equal false
     

      @rental.available_inventory = -1
      @rental.save
      expect(@rental.valid?).must_equal false
      
      @rental.available_inventory = videos(:video1).available_inventory 
      @rental.videos_checked_out_count = -6
      @rental.save
      expect(@rental.valid?).must_equal false
      
    end
  end

  describe 'relationships' do
    before do
      @customer =  customers(:customer1) 
      @video = videos(:video1)
    end
    it 'relates to customer' do
      expect(@rental.customer.videos_checked_out_count).must_equal @customer.videos_checked_out_count
    end

    it 'relates to video' do
      expect(@rental.video.available_inventory).must_equal @video.available_inventory
    end
  end

  describe 'checkout' do
    before do
      @new_rental = Rental.new(
        customer_id: customers(:customer1).id, 
        video_id: videos(:video1).id
      )
    end
    it 'can add a due date to a rental' do
      @new_rental.checkout
      @new_rental.save!

      expect(@new_rental.due_date).must_be_instance_of Date
      expect(@new_rental.due_date).must_equal Date.today + 7

    end

    it 'can add videos_checked_out_count to rental' do
      @new_rental.checkout
      @new_rental.save!

      expect(@new_rental.videos_checked_out_count).must_equal 2
    end

    it ' can add available_inventory to rental' do
      @new_rental.checkout
      @new_rental.save!
      expect(@new_rental.available_inventory).must_equal 8
    end
  end

  describe 'checkin' do
    before do
      @new_rental = Rental.new(
        customer_id: customers(:customer1).id, 
        video_id: videos(:video1).id
      )
    end
    
    it 'can decrease videos_checked_out_count ' do
      @new_rental.checkout
      @new_rental.save!

      @checked_in = @new_rental.checkin
      @checked_in.save!

      expect(@checked_in.videos_checked_out_count).must_equal 1
    end

    it ' can increase available_inventory' do
      @new_rental.checkout
      @new_rental.save!

      @checked_in = @new_rental.checkin
      @checked_in.save!

      expect(@checked_in.available_inventory).must_equal 9
    end
  end

end
