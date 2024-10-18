var chart;
function updateChart(profile_results) {
    require(['https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js'], function (Chart) {
        if (chart != undefined)
        {
            chart.destroy();
        }
        var colors = [];
        for (const i in profile_results)
        {
            colors.push(`#${Math.round(255 - Math.random() * 128).toString(16)}${Math.round(255 - Math.random() * 128).toString(16)}${Math.round(255 - Math.random() * 128).toString(16)}`);
        }
        console.log(profile_results);
        console.log(colors);
        chart = new Chart(document.getElementById("profiler"), {
            type: "bar",
            data: {
                labels: profile_results.map(result => result.callable),
                datasets: [
                    {
                        label: "Minimum (ms)",
                        backgroundColor: colors,
                        data: profile_results.map(result => result.min_msec)
                    },
                    {
                        label: "Average (ms)",
                        backgroundColor: colors,
                        data: profile_results.map(result => result.average_msec)
                    },
                    {
                        label: "Max (ms)",
                        backgroundColor: colors,
                        data: profile_results.map(result => result.max_msec)
                    }
                ]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    });
}
