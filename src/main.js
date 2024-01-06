const { invoke } = window.__TAURI__.tauri;
const { random, round, floor, color, lerpColor } = Drawlite();

$.createComponent("sidebar-item", $.html`
    <div class="performance-sidebar-item">
        <div class="sidebar-canvas-wrapper"><canvas width="100" height="65"></canvas></div>
        <div>
            <span class="sidebar-item-label">\{title}</span>
            <span class="sidebar-item-utilization"></span>
        </div>
    </div>
`);

$.createComponent("perf-left-detail", $.html`
    <div class="perf-left-detail" style="margin: 10px;">
        <span class="gray-text">\{label}</span>
        <br>
        <span style="font-size: 24px;">\{content}</span>
    </div>
`);

$.createComponent("perf-right-detail", $.html`
    <tr class="perf-right-detail">
        <td class="gray-text">\{label}: </td>
        <td style="text-align: left;">\{content}</td>
    </tr>
`);


let tabButtons = $("#tabs").$("*div");
let currTab = 0;

const processes = [];
const bkClr1 = color(255,245,195);
const bkClr2 = color(255,105,40);

function createProcessEl(process) {
    return $("tr")
        .append(
            $("td")
                .append($("svg").attr("src", "./assets/expand-arrow.svg"))
                .append($("img").attr("src", process.img))
                .append($("span").text(process.name))
        )
        .append($("td").text(process.status))
        .append($("td"))
        .append($("td"))
        .append($("td"))
        .append($("td"))
        .append($("td"))
        .append($("td").text(process.id))
}

function updateProcessesTab() {
    for (let i = 0; i < processes.length; i++) {
        let process = processes[i];
        process.cpu = random(0, 100);
        process.memory = random(0, 1000);
        process.disk = random(0, 100);
        process.network = random(0, 100);
        process.gpu = random(0, 100);

        let els = process.el.$("*td");
        els[2]
            .text(process.cpu.toFixed(1) + "%")
            .css({ backgroundColor: lerpColor(bkClr1, bkClr2, process.cpu / 100) })
        els[3]
            .text(process.memory.toFixed(1) + " MB")
            .css({ backgroundColor: lerpColor(bkClr1, bkClr2, process.memory / 100) })
        els[4]
            .text(process.disk.toFixed(1) + " MB/s")
            .css({ backgroundColor: lerpColor(bkClr1, bkClr2, process.disk / 100) })
        els[5]
            .text(process.network.toFixed(1) + " Mbps")
            .css({ backgroundColor: lerpColor(bkClr1, bkClr2, process.network / 100) })
        els[6]
            .text(process.gpu.toFixed(1) + "%")
            .css({ backgroundColor: lerpColor(bkClr1, bkClr2, process.gpu / 100) })
    }
}

let globalStats = {
    // native
    CPUName: "",
    CPUArch: "",
    totalRAM: 0,
    usedRAM: 0,
    totalSwap: 0,
    usedSwap: 0,
    logicalCoreCount: 0,
    physicalCoreCount: 0,
    coresUsages: 0,
    coresFrequencies: 0,
    processesCount: 0,
    disks: new Map(),
    systemUptime: 0,

    // computed
    lastUptimeUpdate: 0,
    avgCoreUsage: 0,
    avgCoreFreq: 0,
    numHandles: 0,
    upTimeStr: "",

    baseSpeed: 0,
    sockets: 1,
    virtualization: "",
    L1CacheSzStr: "",
    L2CacheSzStr: "",
    L3CacheSzStr: "",
};

let currPerfPgIdx = 0;
let cpuUsageHistory = [];
let ramUsageHistory = [];
let swapUsageHistory = [];
let mainCanvas = $("canvas");
let perfPages = [
    {
        title: "CPU",
        graphLabel: "% Utilization",
        hardware: "",
        canvas: $("canvas").attr({
            width: 100,
            height: 65
        }),
        dynDetails: [
            "Utilization", "avgCoreUsage", "%",
            "Speed", "avgCoreFreq", " Ghz",
            "Processes", "processesCount", "",
            "Threads", "processesCount", "",
            "Handles", "numHandles", "",
            "Up time", "upTimeStr", "",
        ],
        constDetails: [
            "Base speed", "baseSpeed", " Ghz",
            "Sockets", "sockets", "",
            "Cores", "physicalCoreCount", "",
            "Logical processors", "logicalCoreCount", "",
            // "Virtualization", "virtualization", "",
            "L1 cache", "L1CacheSzStr", "",
            "L2 cache", "L2CacheSzStr", "",
            "L3 cache", "L3CacheSzStr", "",
        ],
    },
    {
        title: "Memory",
        graphLabel: "Memory usage",
        hardware: "",
        canvas: $("canvas").attr({
            width: 100,
            height: 65
        }),
        dynDetails: [
            // "In use",
            // "Available",
            // "Swap",
            // "Committed",
            // "Cached",
            // "Paged pool",
            // "Non-paged pool"
        ],
        constDetails: [
            "Speed",
            "Slots used",
            "Form factor",
            "Hardware reserved"
        ],
    },
];

function getAverage(arr) {
    let avg = 0;
    for (let i = 0; i < arr.length; i++) {
        avg += arr[i];
    }
    return avg / arr.length;
}

function resizeCanvas() {
    mainCanvas
        .attr({
            width: window.innerWidth - 280,
            height: (window.innerWidth - 280) * 0.5
        })
}

function drawGraph(canvas, data, drawBig) {
    let { background, beginShape, endShape, vertex, noFill, fill, stroke, strokeWeight, get, rect, line } = Drawlite(canvas);
    
    const clr = data[1];

    background(255, 255, 255);

    // draw background lines
    strokeWeight(drawBig ? 2 : 1);
    if (drawBig) {
        stroke(lerpColor(clr, color(255, 255, 255), 0.85));
        let lineSpacing = get.height / 10;
        for (let i = 1; i < 10; i++) {
            line(0, i * lineSpacing, get.width, i * lineSpacing);
        }
        lineSpacing = get.width / 6;
        for (let i = 1; i < 6; i++) {
            line(i * lineSpacing, 0, i * lineSpacing, get.height);
        }
    }

    for (let i = 0; i < data.length; i += 2) {
        const history = data[i];
        const clr = data[i + 1];

        // draw graph
        stroke(clr);
        fill(color(clr.r, clr.g, clr.b, 40));
        beginShape();
        vertex(get.width, get.height);
        let lineX = get.width;
        for (let i = history.length - 1; i >= 0; i--) {
            vertex(lineX, get.height - (history[i] / 100 * get.height));
            lineX -= get.width / 60;
        }
        vertex(lineX, get.height);
        endShape();

        
    }

    // draw graph border
    noFill();
    rect(0, 0, get.width-1, get.height-1);
}

function updateUptime() {
    let now = Date.now();
    globalStats.systemUptime += (now - globalStats.lastUptimeUpdate) / 1000;
    globalStats.lastUptimeUpdate = now;
    let s = globalStats.systemUptime;
    let seconds = ("" + floor(s % 60)).padStart(2, "0");
    let minutes = ("" + floor((s / 60) % 60)).padStart(2, "0");
    let hours = ("" + floor((s / 60 / 60) % 24)).padStart(2, "0");
    let days = floor(s / 60 / 60 / 24);
    globalStats.upTimeStr = `${days}:${hours}:${minutes}:${seconds}`;
}

async function updateCPUCacheSizes() {
    const cacheSizes = await invoke("getLCacheSizes");
    globalStats.L1CacheSzStr = cacheSizes[0] / 1024 + " KB";
    globalStats.L2CacheSzStr = cacheSizes[1] / 1024 + " KB";
    globalStats.L3CacheSzStr = cacheSizes[2] / 1024 / 1024 + " MB";
}

async function updateDisks() {
    let serializedDisks = await invoke("getDisks");
    globalStats.disks.clear();
    for (let i = 0; i < serializedDisks.length; i++) {
        let data = serializedDisks[i];

        // get partition name
        let partitionName = data[1].split("/");
        partitionName = partitionName[partitionName.length - 1];

        // update global disk info
        let diskName = partitionName.slice(0, 3);
        if (globalStats.disks.has(diskName)) {
            // add partition to drive
            globalStats.disks.get(diskName).partitions.push({
                name: data[1],
                totalSpace: Number(data[3]),
                availableSpace: Number(data[4]),
                mountPoint: data[5]
            });
        } else {
            // create drive with partition
            globalStats.disks.set(diskName, {
                type: ["Unknown", "HDD", "SSD"][Number(data[0])],
                format: data[2],
                partitions: [
                    {
                        name: data[1],
                        totalSpace: Number(data[3]),
                        availableSpace: Number(data[4]),
                        mountPoint: data[5]
                    }
                ]
            });
        }
    }
}

async function updatePerformanceTab() {
    // cpu usage stuff
    globalStats.coresUsages = await invoke("getCoresUsages");
    globalStats.avgCoreUsage = round(getAverage(globalStats.coresUsages));
    cpuUsageHistory.push(globalStats.avgCoreUsage);
    if (cpuUsageHistory.length > 61) {
        cpuUsageHistory.shift();
    }

    // cpu frequency stuff
    globalStats.coresFrequencies = await invoke("getCoresFrequencies");
    globalStats.avgCoreFreq = getAverage(globalStats.coresFrequencies) / 1000;

    // processes count
    globalStats.processesCount = await invoke("getProcessesCount");
    
    // ram stuff
    globalStats.usedRAM = await invoke("getUsedMemory");
    let usedRAMGB = (globalStats.usedRAM / 1024 / 1024 / 1024).toFixed(1);
    let totalRAMGB = (globalStats.totalRAM / 1024 / 1024 / 1024).toFixed(1);
    ramUsageHistory.push(globalStats.usedRAM / globalStats.totalRAM * 100);
    if (ramUsageHistory.length > 61) {
        ramUsageHistory.shift();
    }

    // swap stuff
    globalStats.usedSwap = await invoke("getUsedSwap");
    let usedSwapGB = (globalStats.usedSwap / 1024 / 1024 / 1024).toFixed(1);
    let totalSwapGB = (globalStats.totalSwap / 1024 / 1024 / 1024).toFixed(1);
    swapUsageHistory.push(globalStats.usedSwap / globalStats.totalSwap * 100);
    if (swapUsageHistory.length > 61) {
        swapUsageHistory.shift();
    }

    updateUptime();

    // update left details
    const perfPg = perfPages[currPerfPgIdx];
    let dynDetails = $(".perf-left-detail");
    let constDetails = $(".perf-right-detail");

    const isDiskPage = perfPg.title.startsWith("Disk ");
    if (isDiskPage) {
        // for (let i = 0; i < perfPg.dynDetails.length; i += 3) {
        //     let detail = perfPg.dynDetails[i];
        //     let valueName = perfPg.dynDetails[i+1];
        //     let suffix = perfPg.dynDetails[i+2];
        //     let value = globalStats[valueName];
    
        //     switch (suffix) {
        //         case "%": {
        //             value = value.toFixed(0);
        //             break;
        //         }
        //         case " Ghz": {
        //             value = value.toFixed(2);
        //             break;
        //         }
        //     }
            
        //     let spans = dynDetails[i / 3].$("*span");
        //     spans[0].text(detail);
        //     spans[1].text(value + suffix);
        // }
    
        // for (let i = 0; i < perfPg.constDetails.length; i += 2) {
        //     let detail = perfPg.constDetails[i];
        //     let valueName = perfPg.constDetails[i+1];
        //     let suffix = perfPg.constDetails[i+2];
        //     let value = globalStats[valueName];
    
        //     switch (suffix) {
        //         case "%": {
        //             value = value.toFixed(0);
        //             break;
        //         }
        //         case " Ghz": {
        //             value = value.toFixed(2);
        //             break;
        //         }
        //     }
            
        //     let tds = constDetails[i / 3].$("*td");
        //     tds[0].text(detail);
        //     tds[1].text(value + suffix);
        // }
    } else {
        for (let i = 0; i < perfPg.dynDetails.length; i += 3) {
            let detail = perfPg.dynDetails[i];
            let valueName = perfPg.dynDetails[i+1];
            let suffix = perfPg.dynDetails[i+2];
            let value = globalStats[valueName];
    
            switch (suffix) {
                case "%": {
                    value = value.toFixed(0);
                    break;
                }
                case " Ghz": {
                    value = value.toFixed(2);
                    break;
                }
            }
            
            let spans = dynDetails[i / 3].$("*span");
            spans[0].text(detail);
            spans[1].text(value + suffix);
        }
    
        for (let i = 0; i < perfPg.constDetails.length; i += 3) {
            let detail = perfPg.constDetails[i];
            let valueName = perfPg.constDetails[i+1];
            let suffix = perfPg.constDetails[i+2];
            let value = globalStats[valueName];
    
            switch (suffix) {
                case "%": {
                    value = value.toFixed(0);
                    break;
                }
                case " Ghz": {
                    value = value.toFixed(2);
                    break;
                }
            }
            
            let tds = constDetails[i / 3].$("*td");
            tds[0].text(detail);
            tds[1].text(value + suffix);
        }
    }

    // update sidebar stuff
    let sideBarItemIdx = 0;
    $(".sidebar-item-utilization")[sideBarItemIdx++].text(globalStats.avgCoreUsage + "% " + globalStats.avgCoreFreq.toFixed(2) + " Ghz");
    $(".sidebar-item-utilization")[sideBarItemIdx++].text(usedRAMGB + "/" + totalRAMGB + " GB (" + (globalStats.usedRAM / globalStats.totalRAM * 100).toFixed(0) + "%)");
    for (let disk of globalStats.disks) {
        $(".sidebar-item-utilization")[sideBarItemIdx++].html(perfPages[2].constDetails[perfPages[2].constDetails.indexOf("Type") + 1] + "<br>0%");
    }
    // update main graph labels
    if (currPerfPgIdx === 0) {
        $("#perf-utilization").text(globalStats.avgCoreUsage + "%");
    } else if (currPerfPgIdx === 1) {
        $("#perf-utilization").text(usedRAMGB + " GB");
    } else if (isDiskPage) {
        $("#perf-utilization").text("0%");
    }
    switch (currPerfPgIdx) {
        case 0: {
            
            break;
        }
        case 1: {
            
            break;
        }
    }

    // display graphs
    let pageDatas = [
        // cpu history
        [cpuUsageHistory, color(20, 125, 190)],
        // ram history
        [swapUsageHistory, color(0, 25, 175), ramUsageHistory, color(140, 25, 175)],
    ];

    // add disks data to pageDatas
    for (let disk of globalStats.disks) {
        pageDatas.push(
            [[50,50,50,50,50,50,50,50,50], color(80, 170, 10), [50,50,50,50,50,50,50,50,50], color(80, 170, 170)],
        );
    }

    // draw side graphs
    for (let i = 0; i < pageDatas.length; i++) {
        drawGraph(perfPages[i].canvas.el, pageDatas[i], false);
    }

    // draw main graph
    drawGraph(mainCanvas.el, pageDatas[currPerfPgIdx], true);

    // get new data for next frame
    invoke("refreshData");
}

function switchPerformancePg(pgIdx) {
    let pgTitle = $("#perf-pg-title");
    let mainGraphLabel = $("#main-graph-label");
    let pgHardwareName = $("#perf-pg-hardware-name");

    currPerfPgIdx = pgIdx;
    const perfPg = perfPages[pgIdx];

    pgTitle.text(perfPg.title);
    mainGraphLabel.text(perfPg.graphLabel);
    pgHardwareName.text(perfPg.hardware);

    resizeCanvas();

    let sideBarCanvasWrappers = $(".sidebar-canvas-wrapper");
    for (let i = 0; i < perfPages.length; i++) {
        let canvas = perfPages[i].canvas;
        sideBarCanvasWrappers[i].html("").append(canvas);
    }

    mainCanvas.appendTo($("#perf-pg-canvas-container").html(""));

    // update sidebar styles
    let allItems = $(".performance-sidebar-item");
    for (let j = 0; j < allItems.length; j++) {
        if (j === pgIdx) {
            allItems[j].css({
                backgroundColor: "rgb(240, 240, 240)",
                border: "var(--tableBorder)"
            });
        } else {
            allItems[j].css({
                backgroundColor: "transparent",
                border: "2px solid transparent"
            });
        }
    }

    let dynDetails = $("#perf-left-details").html("");
    let constDetails = $("#perf-right-details");
    let tableRows = constDetails.$("*table")[0].$(".rows")[0].html("");

    // fill dynDetails with empty data because will be updated by updatePerformanceTab()
    if (perfPg.title.startsWith("Disk ")) {
        for (let i = 0; i < perfPg.dynDetails.length; i += 3) {
            $("perf-left-detail", {
                label: "",
                content: ""
            }).appendTo(dynDetails)
        }
        
        for (let i = 0; i < perfPg.constDetails.length; i += 2) {
            let detail = perfPg.constDetails[i];
            let value = perfPg.constDetails[i+1];
            $("perf-right-detail", {
                label: detail,
                content: value
            }).appendTo(tableRows)
        }
    } else {
        for (let i = 0; i < perfPg.dynDetails.length; i += 3) {
            $("perf-left-detail", {
                label: "",
                content: ""
            }).appendTo(dynDetails)
        }
        
        for (let i = 0; i < perfPg.constDetails.length; i += 3) {
            let detail = perfPg.constDetails[i];
            let valueName = perfPg.constDetails[i+1];
            let suffix = perfPg.constDetails[i+2];
            $("perf-right-detail", {
                label: detail,
                content: globalStats[valueName] + suffix
            }).appendTo(tableRows)
        }
    }
    

    updatePerformanceTab();
}

function update() {
    switch (currTab) {
        case 0: {
            updateProcessesTab();
            break;
        }
        case 1: {
            updatePerformanceTab();
            break;
        }
    }
}

function switchTab(tabIdx) {
    currTab = tabIdx;

    // update tabs display
    for (let i = 0; i < tabButtons.length; i++) {
        let btn = tabButtons[i];
        let btnStyles = {
            backgroundColor: "rgb(240, 240, 240)",
            padding: "4px",
            borderLeft: "var(--tabsBorder)",
            borderTop: "var(--tabsBorder)",
            borderBottom: "var(--tabsBorder)",
        };
        
        if (i === 0) {
            btnStyles.borderLeft = "none";
        } else if (i === tabButtons.length - 1) {
            btnStyles.borderRight = "var(--tabsBorder)";
        }

        if (i === tabIdx) {
            btnStyles.backgroundColor = "white";
            btnStyles.borderBottom = "none";
        }

        btn.css(btnStyles);
    }

    // display tab
    let tabs = $(".main-tab");
    for (let i = 0; i < tabs.length; i++) {
        let tab = tabs[i];
        if (i === tabIdx) {
            tab.css({ display: "block" });
        } else {
            tab.css({ display: "none" });
        }
    }

    // update display
    update();
}

async function main() {
    globalStats.CPUName = await invoke("getCPUName");
    globalStats.CPUArch = await invoke("getCPUArch");
    globalStats.totalRAM = await invoke("getTotalMemory");
    globalStats.usedRAM = await invoke("getUsedMemory");
    globalStats.totalSwap = await invoke("getTotalSwap");
    globalStats.usedSwap = await invoke("getUsedSwap");
    globalStats.logicalCoreCount = await invoke("getLogicalCoreCount");
    globalStats.physicalCoreCount = await invoke("getPhysicalCoreCount");
    globalStats.processesCount = await invoke("getProcessesCount");
    globalStats.systemUptime = await invoke("getSystemUptime");
    globalStats.lastUptimeUpdate = Date.now();
    await updateDisks();
    updateCPUCacheSizes();

    let diskNum = 0;
    for (let disk of globalStats.disks) {
        const name = disk[0];
        const data = disk[1];

        let totalCapacity = 0;
        let totalAvailable = 0;
        let isSystemDisk = false;

        for (let i = 0; i < data.partitions.length; i++) {
            let part = data.partitions[i];
            totalCapacity += part.totalSpace;
            totalAvailable += part.availableSpace;
            if (part.mountPoint === "/boot/efi") {
                isSystemDisk = true;
            }
        }

        perfPages.push({
            title: `Disk ${diskNum} (${name})`,
            graphLabel: "Active time",
            hardware: "",
            canvas: $("canvas").attr({
                width: 100,
                height: 65
            }),
            dynDetails: [
                "Active time", "%",
                "Average response time", " Ghz",
                "Read soeed", "",
                "Write speed", "",
            ],
            constDetails: [
                "Capacity", (totalCapacity / 1024 / 1024 / 1024).toFixed(2) + " GB",
                "Available", (totalAvailable / 1024 / 1024 / 1024).toFixed(2) + " GB",
                "System disk", (isSystemDisk ? "Yes" : "No"),
                "Format", data.format,
                "Type", data.type,
            ],
        });

        diskNum++;
    }

    perfPages[0].hardware = globalStats.CPUName;
    perfPages[1].hardware = (globalStats.totalRAM / 1024 / 1024 / 1024).toFixed(1) + " GB";

    let sidebarContainer = $("#sidebar-container");
    for (let i = 0; i < perfPages.length; i++) {
        let item = $("sidebar-item", { title: perfPages[i].title });
        item.appendTo(sidebarContainer);
        item.on("click", () => {
            switchPerformancePg(i);
        });
    }

    tabButtons.forEach((btn, idx) => {
        btn.on("click", () => {
            if (currTab !== idx) {
                switchTab(idx);
            }
        });
    });

    let process = {
        name: "Google Chrome",
        img: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Google_Chrome_icon_%28February_2022%29.svg/64px-Google_Chrome_icon_%28February_2022%29.svg.png",
        status: "",
        cpu: 0,
        memory: 1200,
        disk: 0.1,
        network: 10,
        gpu: 2,
        id: 1234,
        el: null
    };
    process.el = createProcessEl(process).appendTo($(".rows")[0]);
    
    processes.push(process);

    switchTab(1);
    switchPerformancePg(0);

    setInterval(update, 1000);
}

window.addEventListener("DOMContentLoaded", main);

window.addEventListener("resize", () => {
    resizeCanvas();
});