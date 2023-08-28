<?php
/* Database connection settings */
$host = 'localhost';
$user = 'root';
$pass = 'password';
$db = 'shootings_db';
$mysqli = new mysqli($host, $user, $pass, $db, 3307) or die($mysqli->error);

$latitudes = array();
$longitudes = array();
$names = array();
$summaries = array();

// Select all the rows in the markers table
$query = "SELECT  `latitude`, `longitude`, `case_name`, `summary` FROM `enhancement_table` ";
$result = $mysqli->query($query) or die('data selection for google map failed: ' . $mysqli->error);

// turn data into php arrays
while ($row = mysqli_fetch_array($result)) {

	$latitudes[] = $row['latitude'];
	$longitudes[] = $row['longitude'];
	$names[] = $row['case_name'];
	$summaries[] = $row['summary'];
}

?>

<!DOCTYPE html>
<html>

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<title>Shooting Incidents Map</title>
	<style>
		body {
			font-family: Arial, sans-serif;
			margin: 0;
			padding: 0;
		}

		header {
			background-color: #333;
			color: white;
			text-align: center;
			padding: 1rem;
			font-family: 'Times New Roman', Times, serif;
		}

		.container {
			max-width: 1200px;
			margin: 0 auto;
			padding: 1rem;
		}

		#map {
			width: 100%;
			height: 70vh;
		}

		.btn-submit {
			background-color: #007bff;
			color: white;
			border: none;
			padding: 0.5rem 1rem;
			cursor: pointer;
			transition: background-color 0.3s;
		}

		.btn-submit:hover {
			background-color: #0056b3;
		}

		h2 {
            color: black; /* Set the heading color to black */
        }

        ul {
            color: black; /* Set the list item color to black */
        }

        em {
            font-style: italic;
            color: black; /* Set the emphasized text color to black */
        }
	</style>
</head>

<body>

	<header>
		<h1>30 Years of Major Shooting Incidents</h1>
		<h3>More information on data and usage can be found <a
				href="https://github.com/matthewconnorgivens/COSC_61_Dataset/wiki" title="Shootings Data Wiki"
				target="_blank">here</a>
	</header>


	<div class="outer-scontainer">
		<div class="row">
			<form class="form-horizontal" action="" method="post" name="frmCSVImport" id="frmCSVImport"
				enctype="multipart/form-data">
				<div class="form-area">
					<button type="submit" id="submit" name="import" class="btn-submit">Reload Data</button><br />
				</div>
			</form>
		</div>

		<div id="map" style="width: 100%; height: 80vh;"></div>

		<script>
			// initialize map
			function initMap() {
				const center_of_us = { lat: 39.8355, lng: -114.0909 };
				var mapOptions = {
					zoom: 3,
					center: center_of_us,
					mapTypeId: google.maps.MapTypeId.SATELLITE
				};

				// get map object
				var map = new google.maps.Map(document.getElementById('map'), mapOptions);

				// creating arrays in javascript from php data
				var Latitudes_js =
					<?php echo json_encode($latitudes); ?>;
				var Longitudes_js =
					<?php echo json_encode($longitudes); ?>;
				var Names_js =
					<?php echo json_encode($names); ?>;
				var Summaries_Js =
					<?php echo json_encode($summaries); ?>;

				// declare array to hold marker objects
				const marker_array = []

				// declare a single info window, will be modified for each call
				const infowindow = new google.maps.InfoWindow();

				// loop through all of the coordinate pairs
				for (let index = 0; index < Latitudes_js.length; index++) {

					// creation of coordinate object
					const myLatLng = { lat: parseFloat(Latitudes_js[index]), lng: parseFloat(Longitudes_js[index]) };

					// setting variable case_name equal to the title of the case
					const case_name = Names_js[index];

					// creating and placing the marker down with the location and the title of the case
					var mark = new google.maps.Marker({
						position: myLatLng,
						map,
						title: case_name,
					});

					// adding the google maps marker object to the array
					marker_array.push(mark);

					// global variable and function variabel declaration to prevent click/double click interference
					var doubleClicked;
					var update_timeout = null;

					// add a listener to the marker object to listen for a 'click'; zooms in and centers the map around that object
					marker_array[index].addListener("click", () => {

						// timeout used to prevent click/double click interference
						update_timeout = setTimeout(function () {
							// check for a double click
							if (!doubleClicked) {
								// checks if info window is open, if it is, close it
								if (infowindow.getMap()) {
									infowindow.close();
								}

								// set center of the map to the marker that was just clicked and zoom in
								map.setCenter(marker_array[index].getPosition());
								var new_zoom = map.getZoom();
								new_zoom = new_zoom * 1.5;
								map.setZoom(new_zoom);
							}
							// timeout between possible clicks is set to 400 milli-seconds
						}, 400);
					});

					// double click listener
					marker_array[index].addListener("dblclick", () => {
						// clear the single click timeout if it goes through
						clearTimeout(update_timeout);

						// setting variable equal to summary string for use in infowindow
						const sum = Summaries_Js[index];

						// set boolean to true to prevent a single click from going through
						doubleClicked = true;

						// dynamic content generation for the infowindow
						infowindow.setContent('<style>' +
							'#content { color: black; }' +
							'</style>' + '<div id="content">' +
							'<div id="siteNotice">' +
							'</div>' +
							'<h1 id="firstHeading" class="firstHeading">' + case_name + '</h1>' +
							'<div id="bodyContent">' +
							'<p><b>' + case_name + '</b>, ' + sum + '</p>' +
							'</div>' +
							'</div>');

						// open info window and anchor it to the marker
						infowindow.open({
							anchor: marker_array[index],
							map,
						});

						// set doubleClicked boolean back to false to allow single clicks again
						doubleClicked = false;
					});
				}
				// when an infowindow is open and the map is clicked, close the infowindow
				google.maps.event.addListener(map, "click", function (event) {
					infowindow.close();
				});



				// google.maps.event.addListener(marker, 'click', function() {
				// 	yourContent.open(map,marker);
				// });
			}

			google.maps.event.addDomListener(window, 'load', initialize);
		</script>

		<!-- Loads the Google Maps API key-->
		<script async defer
			src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAlkRhDYERZsaUr0Iqx5j1nmKXaLIBNUk8&callback=initMap"></script>

		<div>
			<h2>Instructions for Use:</h2>
			<ul>
				<li>Hover over a marker to view the shooting incident's name.</li>
				<li>Click on a marker to zoom in and center it on the map.</li>
				<li>Double-click on a marker to display detailed information; click outside the info window to hide it.</li>
			</ul>
			<p><em>This database and visualization were created by Matthew Givens.</em></p>
		</div>
</body>

</html>