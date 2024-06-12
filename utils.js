function formattedVideoDuration(duration) {

    var seconds = Math.floor(duration / 1000)

    var hours = Math.floor(seconds / 3600)

    var minutes = Math.floor((seconds % 3600) / 60)

    var remainingSeconds = seconds % 60

    var formattedHours = hours < 10 ? '0' + hours : hours
    var formattedMinutes = minutes < 10 ? '0' + minutes : minutes
    var formattedSeconds = remainingSeconds < 10 ? '0' + remainingSeconds : remainingSeconds

    if(hours === 0) {
        return formattedMinutes + ':' + formattedSeconds
    }
    return formattedHours + ':' + formattedMinutes + ':' + formattedSeconds
}
