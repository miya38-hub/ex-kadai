document.addEventListener("turbo:load", () => {
  const elem = document.querySelector("#post_raty");
  if (!elem || typeof Raty === "undefined") return;

  elem.innerHTML = "";

  const raty = new Raty(elem, {
    scoreName: "book[score]",
    number: 5,
    starType: "i",
    starOn: "fa fa-star",
    starOff: "fa fa-star-o",
    starHalf: "fa fa-star-half-o"
  });

  raty.init();
});