#!/usr/bin/liquidsoap

settings.request.metadata_decoders.set(["FFMPEG"])
settings.request.metadata_decoders.duration.set(false)
print("Duration metadata decoding disabled")

settings.server.telnet.set(true)
settings.server.timeout.set(-1.0)
settings.server.telnet.bind_addr.set("0.0.0.0")
settings.harbor.bind_addrs.set(["0.0.0.0"])

settings.log.level.set(1)
settings.server.log.level.set(1)
settings.log.stdout.set(true)

enable_replaygain_metadata()

server.harbor()
interactive.harbor()

set("log.stdout", true)

headers = [
    ("Content-Type","application/json"),
    ("Accept","application/json"),
    # ("Authorization","Bearer #{apiToken}")
]

playlist_data = ref([])
current_index = ref(0)

def api_call(url) =
    print("API Sending GET request to #{url}")
    try
        response = http.get(headers=headers, url)
        print("API Response: #{response}")
        {success = response.status_code == 200, result = "#{response}"}
    catch err do
        print("API #{url} - Error: #{error.kind(err)} - #{error.message(err)}")
        {success = false, result = ""}
    end
  end


  def load_playlist() =
    result = api_call("http://api:8000/api/v1/stations/{{ station_id }}/now-playing-playlist")

    if result.success == true then

        let json.parse (resp : {
            data : {
            songs : [{
                id      : int,
                name    : string,
                artist  : string,
                fileUrl : string
            }]
            }
        }) = result.result

      song_paths = list.map(fun(s) -> s.fileUrl, resp.data.songs)

      playlist_data := song_paths
      current_index := 0
      print("Playlist loaded successfully.")
    else
      print("Failed to fetch playlist.")
    end
  end

load_playlist()

def fetch_next() =
    tracks = !playlist_data
    idx    = !current_index

    # если плейлист пуст
    if list.length(tracks) == 0 then
      print("Playlist empty → silence")
      ""    # пустая строка даст silent source
    # если дошли до конца списка — перезагружаем
    elsif idx >= list.length(tracks) then
        begin
            load_playlist()
        end

      path = list.nth(tracks, idx)
      current_index := idx + 1
      "http://api:8000/api/v1/songs/" ^ path ^ "/stream"

    else
      path = list.nth(tracks, idx)
      current_index := idx + 1
      "http://api:8000/api/v1/songs/" ^ path ^ "/stream"
    end
  end

jingle_src = input.http("http://api:8000/api/v1/stations/{{ station_id }}/jingles/random/stream")

dynamic_src = input.http(fetch_next)

combined_src = rotate(weights = [5,1], [dynamic_src, jingle_src])

source = fallback(track_sensitive=false, [combined_src, blank(duration=5.0)])

output.icecast(
  %mp3,
  host        = "icecast",
  port        = 8004,
  password    = "icecast_source_password",
  mount       = "{{ mount_point }}",
  name        = "{{ station_name }}",
  description = "{{ station_description }}",
  genre       = "Hip-Hop",
  public      = true,
  url = "https://icecast:8004/{{ mount_point }}",
  source
)
