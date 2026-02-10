defmodule UiWeb.VoltageLive do
  use UiWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Ui.PubSub, "voltage")
    {:ok, assign(socket, voltage: 0, history: [])}
  end

  def handle_info({:new_reading, val}, socket) do
    # Keep the last 20 readings for the graph
    new_history = [val | Enum.take(socket.assigns.history, 19)]
    {:noreply, assign(socket, voltage: val, history: new_history)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <h1 class="text-2xl font-bold">Potentiometer Voltage: <%= @voltage %></h1>
      <div class="flex items-end h-64 space-x-1 mt-10 border-b">
        <%= for point <- Enum.reverse(@history) do %>
          <div class="bg-blue-500 w-8" style={"height: #{point / 32768 * 100}%"}></div>
        <% end %>
      </div>
    </div>
    """
  end
end
