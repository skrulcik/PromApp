$(function() {

//Temporary before users are available
var dresses = [{designer:"Faviana", styleNumber:"fe456"},{designer:"Jovani", styleNumber:"JV-967"}];

function loadDresses(){
	$('#dresslist').empty(); //Clears out existing dress list views
	$.each(dresses, function(index, dress) {
		var dressInfo = document.createElement('div');
		dressInfo.setAttribute("class", "col-sm-8 col-md-3");
		var dressInfo_thumb = document.createElement('div');
		dressInfo_thumb.setAttribute("class", "thumbnail dress");
		var dressInfo_thumb_img = document.createElement('img');
		dressInfo_thumb_img.setAttribute("data-src", "holder.js/200x300");
		//TODO: fill in dress with real data
		var dressInfo_thumb_caption = document.createElement('div');
		dressInfo_thumb_caption.setAttribute('class', 'caption');
		var caption_designer = document.createElement('h4');
		var caption_styleNumber = document.createElement('h5');
		caption_designer.innerHTML = dress.designer;
		caption_styleNumber.innerHTML = dress.styleNumber;
		//Add children to parent elements
		dressInfo_thumb_caption.appendChild(caption_designer);
		dressInfo_thumb_caption.appendChild(caption_styleNumber);
		dressInfo_thumb.appendChild(dressInfo_thumb_img);
		dressInfo_thumb.appendChild(dressInfo_thumb_caption);
		dressInfo.appendChild(dressInfo_thumb);
		$('#dresslist').append(dressInfo);
	});
}

loadDresses();
});



