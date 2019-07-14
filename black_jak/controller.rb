class Controller
  attr_accessor :dealer, :player

  def initialize
    @dealer = Dealer.new
    @money = Money.new
    @desk = Desk.new
    @interface = Interface.new
  end

  def start
    @user = User.new
    @user.name = @interface.enter_user_name
    @interface.greeting
    @desk.cards.shuffle
    distribution
  end

  def distribution
    @user.cards = []
    @dealer.cards = []
    2.times { @user.cards << @desk.cards.shift }
    2.times { @dealer.cards << @desk.cards.shift }
    @money.bet_money
    user_step
  end

  def menu(commands)
    @interface.puts_choose_command
    command = @interface.choose_command(commands)
    loop do
      yield(commands, command)
    end
  end

  def user_step
    @interface.puts_hide_cards(@user.cards, @dealer.cards)
    commands = @interface.commands_list(@user.cards)
    menu(commands) do |all_commands, current_command|
      case current_command
      when all_commands.index('Пропустить') then dealer_step
      when all_commands.index('Открыть_карту') then open
      when all_commands.index('Добавить_карту') then add
      end
    end
  end

  def dealer_step
    if @dealer.sum_cards >= 17
      user_step
    else
      @dealer.cards << @desk.cards.shift
      open if @user.cards.size == 3
    end
    user_step
  end

  def open
    @user.sum_cards
    @dealer.sum_cards
    @interface.puts_open_cards(@user.cards, @dealer.cards)
    if @user.rating == @dealer.rating
      draw
    elsif @user.rating < @dealer.rating
      winner_is_user
    else
      winner_is_dealer
    end
  end

  def add
    @user.cards << @desk.cards.shift
    @interface.puts_players_cards(@user.cards, @dealer.cards)
    open if @dealer.cards.size == 3 
    dealer_step
  end

  def draw
    @money.draw
    @interface.puts_draw(@money.user_money)
    request_to_continue
  end

  def winner_is_user
    @money.take_money(@user)
    @interface.puts_winner_is_user(@money.user_money)
    request_to_continue
  end

  def winner_is_dealer
    @money.take_money(@dealer)
    @interface.puts_winner_is_dealer(@money.user_money)
    request_to_continue
  end

  def request_to_continue
    @interface.puts_request_to_continue
    commands = @interface.commands_list_request
    menu(commands) do |all_commands, current_command|
      case current_command
      when all_commands.index('Выход') then abort
      when all_commands.index('Продолжим') then distribution
      end
    end
  end
end
