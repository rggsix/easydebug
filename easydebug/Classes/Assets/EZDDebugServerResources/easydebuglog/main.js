var dataRequest = new XMLHttpRequest();
var autoScroll = true;
var monitoring = true;
var firstRequest = 1;
var curIndex = 0;
var request_st = timest();

window.onload = function () {
    var listView = document.getElementById("listView");
    document.getElementById("request_st").innerHTML = request_st;

    setInterval(() => {
        if (!monitoring) return;

        console.log("requesting...");
        var requestSubURL = String('debugloglist?f_index=' + curIndex + '&request_st=' + request_st + "&first_request=" + firstRequest);
        firstRequest = 0;
        dataRequest.open('get', requestSubURL);
        dataRequest.send();
        dataRequest.onreadystatechange = function () {
            if (dataRequest.readyState == 4 && dataRequest.status == 200) {
                handleMonitorDataResponse();
            }
        }
    }, 1000);

    function handleMonitorDataResponse() {
        var json = JSON.parse(dataRequest.responseText);
        var needRefresh = json["needRefresh"];
        var dataList = json["dataList"];

        if (dataList) {
            dataList.forEach(logData => {
                var nTR = listView.insertRow(listView.rows.length);

                var aEl = document.createElement("a");
                var node = document.createTextNode("查看");
                aEl.appendChild(node);
                aEl.setAttribute("href", "./easydebuglog/logdetail.html?index=" + logData.index);
                aEl.target = "_blank";

                var checkDetailTD = document.createElement("td");
                var indexTD = document.createElement("td");
                var dataTD = document.createElement("td");
                var abInfoTD = document.createElement("td");

                checkDetailTD.appendChild(aEl);
                indexTD.innerText = logData.index;
                dataTD.innerText = logData.date
                abInfoTD.innerText = logData.name;

                nTR.append(checkDetailTD);
                nTR.append(indexTD);
                nTR.append(dataTD);
                nTR.append(abInfoTD);
                // nTR.innerHTML = aEl + " : " + logData.index + " -> " + logData.date + " : " + logData.name;
            });


            if (autoScroll) {
                window.scrollTo(0, document.documentElement.scrollHeight);
            }

            curIndex += dataList.length;
            console.log("current index : %d", curIndex);
        }

        if (needRefresh) {
            curIndex = 0;
            listView.innerHTML = "";
            request_st = timest();
            firstRequest = 1;
            document.getElementById("request_st").innerHTML = request_st;
            console.log("List had refresh.");
        }
    }


    document.getElementById("stopScrollBtn").onclick = function () {
        autoScroll = !autoScroll;
        document.getElementById("stopScrollBtn").value = autoScroll ? "关闭自动滚动" : "开启自动滚动";
    }

    document.getElementById("stopMonitoring").onclick = function () {
        monitoring = !monitoring;
        document.getElementById("stopMonitoring").value = monitoring ? "关闭监听" : "开启监听";
    }

    document.getElementById("clearList").onclick = function () {
        listView.innerHTML = "";
    }

}

function timest() {
    var tmp = Date.parse(new Date()).toString();
    tmp = tmp.substr(0, 10);
    return tmp;
}
