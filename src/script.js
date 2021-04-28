const regex1 = /uses: ([a-z0-9-]*?\/[a-z0-9-]*?)@/g;

function fetchLatest(packageName) {

  return new Promise((resolve, reject) => {

    const url = `https://api.github.com/repos/${packageName}/releases/latest`;

    fetch(url).then(response => response.json()).then(response => {

      if (response.tag_name) {
        resolve({packageName: packageName, version: response.tag_name})
      } else {
        reject('`tag_name` could not be found in the result from Github')
      }
    })

  })
}

function main() {

  let txt = document.getElementById("ga_script_in").value;

  let matches = [];

  let m;

  while ((m = regex1.exec(txt)) !== null) {

    // This is necessary to avoid infinite loops with zero-width matches
    if (m.index === regex1.lastIndex) {
      regex1.lastIndex++;
    }
    m.forEach((match, groupIndex) => {

      if (groupIndex === 1) {
        console.log(`Found match ${match}`)

        matches.push(match)

      }
    });

  }

  console.log(matches)

  const umatches = [...new Set(matches)];

  let promises = umatches.map(fetchLatest);

  Promise.all(promises).then(response => {

    console.log(response)

    response.forEach(({packageName, version}) => {

      let regex2 = `uses: ${packageName}@.*`
      let replacement = `uses: ${packageName}@${version}`

      let re = new RegExp(regex2, 'g')
      txt = txt.replace(re, replacement);

    })

    // console.log(txt)

    document.getElementById("ga_script_out").value = txt;


  });

}

document.addEventListener('DOMContentLoaded', (event) => {

  document.getElementById('submit').addEventListener("click", main);

})

