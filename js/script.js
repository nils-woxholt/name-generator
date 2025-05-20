document.addEventListener('DOMContentLoaded', () => {
    // Name lists as specified in the instructions
    const nameList1 = [
        'emerald',
        'tiny',
        'sugar',
        'sweet',
        'silly',
        'fizzy',
        'fluffy',
        'dreamy',
        'sparkly',
        'fruity',

    ];
    
    const nameList2 = [
        'soda',
        'kandi',
        'snail',
        'pudding',
        'cookie',
        'dash',
        'star',
        'bunny',
        'puff',
        'duck',
        'snek',
        'worm',
        'onastring',
        'pup',
        'narwhal',
    ];

    // Get DOM elements
    const generateBtn = document.getElementById('generateBtn');
    const resultContainer = document.getElementById('resultContainer');
    const generatedNameElement = document.getElementById('generatedName');

    // Add click event listener to the generate button
    generateBtn.addEventListener('click', generateRandomName);

    // Function to generate a random name
    function generateRandomName() {
        // Randomly select an item from each list
        const randomName1 = nameList1[Math.floor(Math.random() * nameList1.length)];
        const randomName2 = nameList2[Math.floor(Math.random() * nameList2.length)];
        
        // Join the two values
        const fullName = `${randomName1} ${randomName2}`;
        
        // Display the generated name
        generatedNameElement.textContent = fullName;
        resultContainer.style.display = 'block';
        
        // Add a little animation to the result
        resultContainer.classList.add('animate__animated', 'animate__fadeIn');
    }
});
